const { ethers, network } = require("hardhat")
const {expect} = require("chai")

let rewardToken, stakeAmount, user, allowance, staking


beforeEach(async function () {
    // environment preparation, deploy token & staking contracts
    const accounts = await ethers.getSigners()
    user = await accounts[3] // User is the second account	
    
    const Token = await ethers.getContractFactory("Token")
    rewardToken = await Token.deploy()

    const Vesting = await ethers.getContractFactory("Vesting")
    vesting = await Vesting.deploy(rewardToken.address)

})

describe("Vesting test", async function () {
    it("Stake", async function () {
        const [user] = await ethers.getSigners()
        const amount = 1000

        await rewardToken.connect(user).approve(vesting.address, 2 *amount)
        const balBefore = await rewardToken.balanceOf(user.address)
        await vesting.connect(user).deposit(user.address,amount,1707559629)
        const balMid = await rewardToken.balanceOf(user.address)
        expect(balMid).to.equal(balBefore.sub(amount))
        await vesting.connect(user).deposit(user.address,amount,1707569629)

        const ids = await vesting.getBeneficiaryIds(user.address)
        const id = await vesting.getAllLockboxDetails()
        console.log(id)
        await network.provider.request({ method: "evm_mine", params: [1782583106] })
        await vesting.connect(user).withdraw(0);
        const balAfter = await rewardToken.balanceOf(user.address)
        expect(balAfter).to.equal(balMid)
    })
})


