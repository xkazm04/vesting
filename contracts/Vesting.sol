// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// Backup vesting contract 

contract Vesting is ReentrancyGuard, Ownable  {
    IERC20 token;

    struct LockBoxStruct {
        address beneficiary;
        uint balance;
        uint releaseTime;
    }

    LockBoxStruct[] public lockBoxStructs; // This could be a mapping by address, but these numbered lockBoxes support possibility of multiple tranches per address

    event LogLockBoxDeposit(address sender, uint amount, uint releaseTime);   
    event LogLockBoxWithdrawal(address receiver, uint amount);

    constructor(address tokenContract) {
        token = IERC20(tokenContract);
    }

    ///@notice Deposit/Timelock specific amount after which will be added to beneficiary address
    function deposit(address beneficiary, uint amount, uint releaseTime) public returns(bool success) {
        token.transferFrom(msg.sender, address(this), amount);
        LockBoxStruct memory l;
        l.beneficiary = beneficiary;
        l.balance = amount;
        l.releaseTime = releaseTime; // Unix timestamp 
        lockBoxStructs.push(l);
        emit LogLockBoxDeposit(msg.sender, amount, releaseTime);
        return true;
    }

    ///@notice - Withdraw function to be called by beneficiary 
    ///@param lockBoxNumber - Lockbox number to withdraw from
    function withdraw(uint lockBoxNumber) public nonReentrant returns(bool success) {
        LockBoxStruct storage l = lockBoxStructs[lockBoxNumber];
        require(l.releaseTime <= block.timestamp, 'Vesting: current time is before release time');
        uint amount = l.balance;
        l.balance = 0;
        token.approve(address(this), amount);
        token.transferFrom(address(this), l.beneficiary, amount);
        emit LogLockBoxWithdrawal(msg.sender, amount);
        return true;
    }

    ///@notice - Retrieve all lockboxes with details
    function getAllLockboxDetails () public view returns(uint[] memory, address[] memory, uint[] memory, uint[] memory) {
        uint[] memory lockBoxIds = new uint[](lockBoxStructs.length);
        address[] memory beneficiaries = new address[](lockBoxStructs.length);
        uint[] memory balances = new uint[](lockBoxStructs.length);
        uint[] memory releaseTimes = new uint[](lockBoxStructs.length);
        for (uint i = 0; i < lockBoxStructs.length; i++) {
            LockBoxStruct storage l = lockBoxStructs[i];
            lockBoxIds[i] = i;
            beneficiaries[i] = l.beneficiary;
            balances[i] = l.balance;
            releaseTimes[i] = l.releaseTime;
        }
        ///@return - Array of IDs, array of beneficiaries, array of balances, array of release times
        return (lockBoxIds, beneficiaries, balances, releaseTimes);
    }

    ///@notice - Retrieve all lockbox ids for a specific beneficiary
    ///@param beneficiary - Address of beneficiary
    function getBeneficiaryIds(address beneficiary) public view returns(uint[] memory) {
        uint[] memory result = new uint[](lockBoxStructs.length);
        uint counter = 0;
        for (uint i = 0; i < lockBoxStructs.length; i++) {
            if (lockBoxStructs[i].beneficiary == beneficiary) {
                result[counter] = i;
                counter++;
            }
        }
        uint[] memory result2 = new uint[](counter);
        for (uint i = 0; i < counter; i++) {
            result2[i] = result[i];
        }
        return result2;
    }

    ///@notice - Retrieve lockbox details
    function getLockboxDetail (uint lockBoxNumber) public view returns(address beneficiary, uint balance, uint releaseTime) {
        LockBoxStruct storage l = lockBoxStructs[lockBoxNumber];
        return (l.beneficiary, l.balance, l.releaseTime);
    }

    ///@notice - Admin can withdraw funds in case of emergency
    function emergencyWithdrawal(uint256 _amount) public onlyOwner {
        token.approve(address(this), _amount);
        token.transferFrom(address(this), msg.sender, _amount);
    }

    ///@notice - Admin can transfer ownership
    function transferOwnership(address newOwner) public override onlyOwner {
        super.transferOwnership(newOwner);
    }

}