// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title EasyBet - 去中心化彩票系统
contract EasyBet is ERC721, Ownable {
    event ActivityCreated(uint256 indexed activityId, string name, string[] options, uint256 betDeadline, uint256 resultTime);
    event BetPlaced(uint256 indexed activityId, uint256 indexed tokenId, address player, uint256 optionIndex, uint256 amount);
    event ActivityEnded(uint256 indexed activityId, uint256 winningOption);
    event RewardClaimed(address indexed player, uint256 amount);

    struct Activity {
        string name;
        string[] options;
        uint256 betDeadline;
        uint256 resultTime;
        uint256 totalPool;
        bool ended;
        uint256 winningOption;
        mapping(uint256 => BetInfo[]) bets;
    }

    struct BetInfo {
        address player;
        uint256 tokenId;
        uint256 amount;
        bool claimed;
    }

    uint256 public nextActivityId = 1;
    uint256 public nextTokenId = 1;

    mapping(uint256 => Activity) public activities;

    // tokenId => activity 信息
    mapping(uint256 => uint256) public tokenToActivity;
    mapping(uint256 => uint256) public tokenToOption;
    mapping(uint256 => uint256) public tokenToAmount;

    constructor() ERC721("EasyBetTicket", "EBT") Ownable(msg.sender) {}

    // 公证人创建新活动
    function createActivity(
        string memory _name,
        string[] memory _options,
        uint256 _betDeadline,
        uint256 _resultTime
    ) external onlyOwner {
        require(_options.length >= 2, "Need >=2 options");
        require(_resultTime > _betDeadline, "Invalid time");

        uint256 activityId = nextActivityId++;
        Activity storage a = activities[activityId];
        a.name = _name;
        a.betDeadline = _betDeadline;
        a.resultTime = _resultTime;
        for (uint256 i = 0; i < _options.length; i++) {
            a.options.push(_options[i]);
        }

        emit ActivityCreated(activityId, _name, _options, _betDeadline, _resultTime);
    }

    // 玩家下注购买票
    function placeBet(uint256 activityId, uint256 optionIndex) external payable {
        Activity storage a = activities[activityId];
        require(block.timestamp < a.betDeadline, "Betting closed");
        require(optionIndex < a.options.length, "Invalid option");
        require(msg.value > 0, "Need ETH");

        uint256 tokenId = nextTokenId++;
        _safeMint(msg.sender, tokenId);

        a.totalPool += msg.value;
        a.bets[optionIndex].push(BetInfo(msg.sender, tokenId, msg.value, false));

        tokenToActivity[tokenId] = activityId;
        tokenToOption[tokenId] = optionIndex;
        tokenToAmount[tokenId] = msg.value;

        emit BetPlaced(activityId, tokenId, msg.sender, optionIndex, msg.value);
    }

    // 公证人公布结果
    function endActivity(uint256 activityId, uint256 winningOption) external onlyOwner {
        Activity storage a = activities[activityId];
        require(!a.ended, "Already ended");
        require(block.timestamp >= a.resultTime, "Too early");
        require(winningOption < a.options.length, "Invalid option");

        a.ended = true;
        a.winningOption = winningOption;

        emit ActivityEnded(activityId, winningOption);
    }

    // 玩家领奖
    function claimReward(uint256 tokenId) external {
        uint256 activityId = tokenToActivity[tokenId];
        uint256 option = tokenToOption[tokenId];

        Activity storage a = activities[activityId];
        require(a.ended, "Not ended");
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(option == a.winningOption, "Not winning ticket");

        BetInfo[] storage winners = a.bets[a.winningOption];
        uint256 totalWinners = winners.length;
        require(totalWinners > 0, "No winners");

        uint256 reward = a.totalPool / totalWinners;

        for (uint256 i = 0; i < winners.length; i++) {
            if (winners[i].tokenId == tokenId) {
                require(!winners[i].claimed, "Already claimed");
                winners[i].claimed = true;
                payable(msg.sender).transfer(reward);
                emit RewardClaimed(msg.sender, reward);
                return;
            }
        }
        revert("Invalid ticket");
    }

    // 查询活动信息（供前端显示）
    function getActivity(uint256 id)
        external
        view
        returns (string memory name, string[] memory options, uint256 pool, bool ended, uint256 winningOption)
    {
        Activity storage a = activities[id];
        return (a.name, a.options, a.totalPool, a.ended, a.winningOption);
    }
}
