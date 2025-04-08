// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

//  add oz ownable ?
import "@openzeppelin/contracts/utils/Pausable.sol"; // pausing system functioning in the event of exploit etc.
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

/*
 _   _       _       ____  _                             
| \ | |_   _| |_ ___/ ___|| |_ ___  _ __ __ _  __ _  ___ 
|  \| | | | | __/ __\___ \| __/ _ \| '__/ _` |/ _` |/ _ \
| |\  | |_| | |_\__ \___) | || (_) | | | (_| | (_| |  __/
|_| \_|\__,_|\__|___/____/ \__\___/|_|  \__,_|\__, |\___|
                                              |___/      

*/

/*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
/*   Interface for developers building using nuts_storage     */
/*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

interface INUTSStorage {
    function setImportant(uint256) external;
    function important() external view returns (uint256);
    function isRegistered(address) external view returns (bool);
}

contract NUTS_storage is OwnableUpgradeable, UUPSUpgradeable, PausableUpgradeable {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  State Variables                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    uint256 private important;
    mapping(address => bool) private isRegistered;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  Custom Errors                             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    error NotAuthorized();
    error AlreadyRegistered();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  Events                                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    event UserAuthorized(address indexed user);

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°•´.*:*/
    /*                  Modifiers                              */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´•*/

    modifier onlyAuthUsers() {
        if (!isRegistered[msg.sender]) revert NotAuthorized();
        _;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  Initializer                               */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    constructor() {
        // _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Pausable_init();
        __Ownable_init(initialOwner);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  External Methods                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function addAuthUser(address _authUser) external onlyOwner {
        if (isRegistered[_authUser]) revert AlreadyRegistered();
        isRegistered[_authUser] = true;
        emit UserAuthorized(_authUser);
    }

    function setImportant(uint256 _important) external onlyAuthUsers {
        important = _important;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°•´.*:*/
    /*                  Pause functions                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´•*/

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°•´.*:*/
    /*                  Upgrade functions                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´•*/

    // Over-write the _authorizeUpgrade method so that only Owner can upgrade
    function _authorizeUpgrade(address) internal view override {
        _checkOwner();
    }
}
