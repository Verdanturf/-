#一、项目简介

EasyBet 是一个去中心化的彩票/竞猜系统（DApp）

它允许：

公证人（部署者）创建新的竞猜项目；

玩家使用以太币下注购买彩票（ERC721 形式）；

竞猜结果公布后，胜利者自动平分奖池；

票据可在结果公布前转移，具备流动性；

所有过程全程上链、透明可信。

🧩 二、主要功能模块
1️⃣ 公证人功能

创建新的竞猜项目：

输入项目名、候选选项（如“TeamA,TeamB”）；

设置下注截止时间、结果公布时间；

公布结果、结算奖金。

2️⃣ 玩家功能

连接 MetaMask 钱包；

查看所有活动与选项；

选择活动 + 下注金额（单位 ETH）；

购买后自动获得一张彩票（ERC721 Token）；

活动结束后，若中奖则可领取奖金。

3️⃣ 系统合约

票据采用 ERC721 标准；

竞猜记录保存在 Activity 结构体；

奖金平分算法基于胜者数量；

所有状态与资金流均可链上追溯。

⚙️ 三、智能合约设计说明

文件路径：contracts/EasyBet.sol

主要结构：

函数	功能
createActivity(string name, string[] options, uint256 betDeadline, uint256 resultTime)	创建竞猜活动（仅公证人）
placeBet(uint256 id, uint256 option)	玩家下注（发送 ETH）
endActivity(uint256 id, uint256 winningOption)	公证人公布结果
claimReward(uint256 tokenId)	玩家领取奖金
getActivity(uint256 id)	查看活动详情

合约继承：

ERC721 (票据系统)

Ownable (公证人权限)

Solidity 版本 ^0.8.20

💻 四、前端实现说明（React + Ethers.js）

文件路径：frontend/src/App.js

主要组件：

钱包连接（MetaMask）；

活动创建、下注、结算、领奖等表单；

实时展示活动信息；

合约调用使用 ethers.js。

五、项目运行步骤
1️⃣ 安装依赖
npm install
cd frontend
npm install ethers

2️⃣ 启动本地区块链
npx hardhat node

3️⃣ 部署合约
npx hardhat run scripts/deploy.ts --network localhost


记录控制台输出的合约地址。

4️⃣ 修改前端合约地址

打开：

frontend/src/App.js


找到：

const contractAddress = "YOUR_DEPLOYED_CONTRACT_ADDRESS";


替换为你的部署地址。

5️⃣ 启动前端
cd frontend
npm start


在浏览器访问：

http://localhost:3000
