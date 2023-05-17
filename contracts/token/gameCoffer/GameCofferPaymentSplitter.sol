//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "../../core/contract-upgradeable/VersionUpgradeable.sol";
import "./PaymentSplitterDailyUpgradeable.sol";

contract GameCofferPaymentSplitter is
    Initializable,
    AccessControlEnumerableUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    PaymentSplitterDailyUpgradeable,
    VersionUpgradeable
{

    event GameCofficientUpdated(address[] payees, uint256[] shares);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // GameCofficientBallot
    address gameCofficientBallot;
    // Ballot status 0: ended, 1: started
    uint ballotStatus;

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    function _version() internal pure virtual override returns (uint256) {
        return 1;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address ballot) public initializer {
        __AccessControlEnumerable_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __VersionUpgradeable_init();

        __GameCofficientBallot_init(ballot);
        __BallotStatus_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function __GameCofficientBallot_init(address ballot) internal initializer {
        require(ballot != address(0), "Ballot is the zero address");
        gameCofficientBallot = ballot;
    }

    function __BallotStatus_init() internal initializer {
        ballotStatus = 0;
    }

    function openBallot() public {
        require(ballotStatus == 0, "Ballot is already opened");
        ballotStatus = 1;
        // GameCofficientBallot(gameCofficientBallot).openBallot();
    }

    function updateGameCofficient() public {
        require(_msgSender() == gameCofficientBallot, "Caller is not the ballot");

        /* (
            bool success,
            mapping(address => uint256) newGameCofficient
        ) = GameCofficientBallot(gameCofficientBallot).getGameCofficient();

        if (!success) {
            revert("Ballot is not ended probably");
        } */

        address[] memory __payees = new address[](2);
        uint256[] memory __shares = new uint256[](2);

        __payees[0] = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        __payees[1] = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

        __shares[0] = 1;
        __shares[1] = 1;

        __UpdateGameCofficient(__payees, __shares);

        emit GameCofficientUpdated(__payees, __shares);

    }


}
