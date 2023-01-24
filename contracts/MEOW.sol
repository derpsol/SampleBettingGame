// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC20.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256);

    function getApproved(uint256 tokenId) external view returns (address);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function minterOf(uint256 tokenId) external view returns (address);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

    function tokensOfOwner(address owner)
        external
        view
        returns (uint256[] memory);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;
}

contract Meow is ERC20, Ownable {
    IERC721 NFT;
    uint256 seed;
    uint256 public gamePrice = 0.01 ether;
    uint256 public waitingId = 0;
    uint256 private waitingNumber;
    address public teamAddress;
    uint256 public jackpotAmount = 0;
    address[] private stakers;
    mapping(address => uint256) public stakeAmount;
    uint256 public stakeTotal;

    using SafeMath for uint256;

    event GameStarted(uint256 tokenId1, uint256 tokenId2);

    constructor(address _nftAddress, address _teamAddress)
        ERC20("Meow", "Meow")
    {
        NFT = IERC721(_nftAddress);
        teamAddress = _teamAddress;
        seed = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty))
        );
    }

    function decimals() public view virtual override returns (uint8) {
        return 1;
    }

    function stake(uint256 amount) external {
        transferFrom(msg.sender, address(this), amount);
        if (stakeAmount[msg.sender] == 0) {
            stakers.push(msg.sender);
        }
        stakeAmount[msg.sender] += amount;
        stakeTotal += amount;
    }

    function unStake(uint256 amount) external {
        require(
            amount < stakeAmount[msg.sender],
            "Try to unstake more than staked amount"
        );
        transfer(msg.sender, amount);
        if (stakeAmount[msg.sender] == amount) {
            for (uint256 index = 0; index < stakers.length; index++) {
                if (stakers[index] == msg.sender) {
                    stakers[index] = stakers[stakers.length - 1];
                    break;
                }
            }
            stakers.pop();
        }
        stakeAmount[msg.sender] -= amount;
        stakeTotal -= amount;
    }

    function joinLobby(uint256 tokenId) external payable {
        require(waitingId != tokenId, "ALEADY_IN_LOBBY");
        require(NFT.ownerOf(tokenId) == _msgSender(), "NOT_OWNER");
        require(gamePrice == msg.value, "Amount doesn't equal msg.value");

        if (waitingId == 0) {
            waitingId = tokenId;
            waitingNumber = getRandomNumber();
        } else {
            startGame(tokenId);
            emit GameStarted(waitingId, tokenId);
            waitingId = 0;
        }
    }

    function leaveLobby(uint256 tokenId) external {
        require(NFT.ownerOf(tokenId) == _msgSender(), "NOT_OWNER");
        require(waitingId == tokenId, "NOT_IN_LOBBY");
        waitingId = 0;
    }

    function startGame(uint256 tokenId) internal {
        // start game
        uint256 nextNumber = getRandomNumber();
        address waitingAddress = NFT.ownerOf(waitingId);
        address oppositeAddress = NFT.ownerOf(tokenId);
        _mint(waitingAddress, 1);
        _mint(oppositeAddress, 1);

        if (waitingNumber == nextNumber) {
            sendPrice(waitingAddress, gamePrice);
            sendPrice(oppositeAddress, gamePrice);
        } else {
            if (waitingNumber > nextNumber) {
                sendPrice(waitingAddress, gamePrice);
                NFT.transferFrom(oppositeAddress, waitingAddress, tokenId);
            } else {
                sendPrice(oppositeAddress, gamePrice);
                NFT.transferFrom(waitingAddress, oppositeAddress, waitingId);
            }
            sendPrice(teamAddress, 1 ether);
            jackpotAmount += 9 ether;
        }

        if (waitingNumber == 77777)
            jackpot(waitingAddress, oppositeAddress, nextNumber);
        if (nextNumber == 77777)
            jackpot(oppositeAddress, waitingAddress, waitingNumber);
    }

    function jackpot(
        address rolled,
        address other,
        uint256 otherNumber
    ) internal {
        if (otherNumber == 77777) {
            sendPrice(rolled, jackpotAmount.mul(3).div(10));
            sendPrice(other, jackpotAmount.mul(3).div(10));
        } else {
            sendPrice(rolled, jackpotAmount.mul(5).div(10));
            sendPrice(other, jackpotAmount.mul(1).div(10));
        }
        distributeToStakers();
        jackpotAmount = 0;
    }

    function distributeToStakers() internal {
        for (uint256 index = 0; index < stakers.length; index++) {
            address stakerAddress = stakers[index];
            sendPrice(
                stakerAddress,
                jackpotAmount
                    .mul(4)
                    .div(10)
                    .mul(stakeAmount[stakerAddress])
                    .div(stakeTotal)
            );
        }
    }

    function getRandomNumber() internal view returns (uint256) {
        return
            (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
                100000) + 1;
    }

    function setTeamAddress(address newTeamAddress) external onlyOwner {
        teamAddress = newTeamAddress;
    }

    function sendPrice(address receiver, uint256 amount) internal {
        (bool os, ) = payable(receiver).call{value: amount}("");
        require(os);
    }

    function setGamePrice(uint256 newGamePrice) external onlyOwner {
        gamePrice = newGamePrice;
    }

    function setNftAddress(address newNftAddress) external onlyOwner {
        NFT = IERC721(newNftAddress);
    }
}

