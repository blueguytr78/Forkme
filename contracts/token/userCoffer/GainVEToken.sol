//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../../core/contract-upgradeable/VersionUpgradeable.sol";
import "../../core/contract-upgradeable/interface/IERCMINTExt20.sol";
import "../../providers/datetime/DateTime.sol";

contract GainVEToken is
    Initializable,
    AccessControlEnumerableUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    VersionUpgradeable
{
    event DepositZOIC(
        address indexed user,
        uint256 tokenZOICAmount,
        uint256 veTokenAmount,
        uint256 depositDuration
    );

    event redeemZOIC(
        address indexed user,
        uint256 tokenZOICAmount,
        uint256 veTokenAmount
    );

    // the role that can pause the contract
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    // the role that used for upgrading the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    // admin role
    bytes32 public constant ADMIN = keccak256("ADMIN");

    struct depositRecord {
        uint256 startTimestamp;
        uint256 duration;
        uint256 amount;
    }

    mapping(address => depositRecord[]) public depositRecords;

    mapping(uint256 => uint256) public veTokenRewardCoifficent;
    uint256[] public veTokenRewardCoifficentIndex;

    address public veTokenAddress;
    address public tokenZOICAddress;
    address public userCofferAddress;

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

    function initialize(
        address _veToken,
        address _tokenZOIC,
        address _userCofferAddress
    ) public initializer {
        __AccessControlEnumerable_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __VersionUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(ADMIN, msg.sender);

        tokenAddress_init(_veToken, _tokenZOIC, _userCofferAddress);
        veTokenRewardCoifficent_init(uint256[], uint256[]);
    }

    function tokenAddress_init(
        address _veToken,
        address _tokenZOIC,
        address _userCofferAddress
    ) internal initializer {
        veTokenAddress = _veToken;
        tokenZOICAddress = _tokenZOIC;
        userCofferAddress = _userCofferAddress;
    }

    function _veTokenRewardCoifficent_init(uint256[] veTokenAmount,uint256[] rewardCoifficient) public onlyRole(UPGRADER_ROLE) {
        veTokenRewardCoifficent_init(veTokenAmount, rewardCoifficient);
    }

    function veTokenRewardCoifficent_init(uint256[] veTokenAmount,uint256[] rewardCoifficient) internal {
        require(veTokenAmount.length == rewardCoifficient.length, "veTokenAmount and rewardCoifficient length must be equal");
        for(uint256 i = 0; i < veTokenAmount.length; i++){
            veTokenRewardCoifficent[veTokenAmount[i]] = rewardCoifficient[i];
            veTokenRewardCoifficentIndex[i] = veTokenAmount[i];
        }

    }

    function deposit(uint256 amount) public nonReentrant whenNotPaused {

        IERC20Upgradeable tokenZOIC = IERC20Upgradeable(tokenZOICAddress);

        address userAddress = _msgSender();

        require(
            tokenZOIC.allowance(userAddress, address(this)) >= amount,
            "Must approve first"
        );

        SafeERC20Upgradeable.safeTransferFrom(
            tokenZOIC,
            userAddress,
            userCofferAddress,
            amount
        );



        IERCMINTExt20 veToken = IERCMINTExt20(veTokenAddress);
        veToken.mint(userAddress, amount);

        IERC20Upgradeable veToken = IERC20Upgradeable(veTokenAddress);
        SafeERC20Upgradeable.safeTransferFrom(
            vetoken,
            veTokenAddress,
            userAddress,
            amount
        )
    }
}
