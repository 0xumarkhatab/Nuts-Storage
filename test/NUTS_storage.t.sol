// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
 _   _       _       ____  _                             
| \ | |_   _| |_ ___/ ___|| |_ ___  _ __ __ _  __ _  ___ 
|  \| | | | | __/ __\___ \| __/ _ \| '__/ _` |/ _` |/ _ \
| |\  | |_| | |_\__ \___) | || (_) | | | (_| | (_| |  __/
|_| \_|\__,_|\__|___/____/ \__\___/|_|  \__,_|\__, |\___|
                                              |___/       
*/

/*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
/*          Foundry Tests for NUTS_storage Contract           */
/*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

// Import Foundry’s standard test library which provides essential cheatcodes and assertions.
import "forge-std/Test.sol";
// Import the contract under test.
import "../src/NUTS_storage.sol";

contract NUTSStorageTest is Test {
    // ------------------------------------------------------------------
    //  STATE VARIABLES & TEST ADDRESSES
    // ------------------------------------------------------------------
    
    // Instance of the NUTS_storage contract that will be deployed.
    NUTS_storage public nuts;
    // Generate specific test addresses using Foundry's makeAddr for clarity.
    address public owner = makeAddr("owner");
    address public authUser = makeAddr("authuser");
    address public nonAuthUser = makeAddr("nonauthuser");

    // ------------------------------------------------------------------
    //  EVENT DECLARATION FOR TESTING EVENT EMISSION
    // ------------------------------------------------------------------
    
    // This event declaration should match the signature of the event in the contract.
    event UserAuthorized(address indexed user);

    // ------------------------------------------------------------------
    //  SETUP FUNCTION: DEPLOYMENT & INITIALIZATION
    // ------------------------------------------------------------------
    
    /**
     * @dev setUp() runs before each test case. It deploys the NUTS_storage contract and
     * calls its initialize() function to simulate the constructor behavior for upgradeable contracts.
     */
    function setUp() public {
        // ─────────────────────────────────────────────────────────────────
        // Simulate transactions from the owner address during deployment.
        // ─────────────────────────────────────────────────────────────────
        vm.prank(owner);              // Set msg.sender to owner.
        nuts = new NUTS_storage();      // Deploy a new instance of NUTS_storage.
        
        // ─────────────────────────────────────────────────────────────────
        // Initialize the contract as the owner. Since constructors are disabled,
        // we use initialize() to set up initial state (owner in this case).
        // ─────────────────────────────────────────────────────────────────
        vm.prank(owner);              // Again, force the msg.sender to be owner.
        nuts.initialize(owner);         // Initialize the contract with owner.
    }

    // ------------------------------------------------------------------
    //  TEST CASE: ONLY OWNER CAN ADD AN AUTHORIZED USER
    // ------------------------------------------------------------------
    
    /**
     * @dev testOnlyOwnerCanAddAuthUser verifies that addAuthUser can only be called by the owner.
     *      - A call from a non-owner should revert.
     *      - A call from the owner should succeed.
     */
    function testOnlyOwnerCanAddAuthUser() public {
        // ────────────────────────────────────────────────
        // Negative Test: Ensure non-owner cannot add an authorized user.
        // ────────────────────────────────────────────────
        vm.prank(nonAuthUser);         // Set msg.sender to nonAuthUser.
        vm.expectRevert();             // Expect the function to revert (non-authorized call).
        nuts.addAuthUser(authUser);    // Attempt to add authUser; should fail.

        // ────────────────────────────────────────────────
        // Positive Test: Allow the owner to add an authorized user.
        // ────────────────────────────────────────────────
        vm.prank(owner);               // Set msg.sender to owner.
        nuts.addAuthUser(authUser);    // Add authUser successfully.
    }

    // ------------------------------------------------------------------
    //  TEST CASE: REVERT SET IMPORTANT FOR NON-AUTHORIZED USER
    // ------------------------------------------------------------------
    
    /**
     * @dev testSetImportantRevertsForNonAuthorized confirms that non-authorized accounts
     *      cannot call setImportant(), expecting a revert.
     */
    function testSetImportantRevertsForNonAuthorized() public {
        // ────────────────────────────────────────────────
        // Set the sender to nonAuthUser and attempt to update "important".
        // ────────────────────────────────────────────────
        vm.prank(nonAuthUser);         // Set msg.sender to nonAuthUser.
        vm.expectRevert();             // Expect a revert due to not being an authorized user.
        nuts.setImportant(42);         // Attempt to set "important" to 42; should revert.
    }

    // ------------------------------------------------------------------
    //  TEST CASE: SUCCESSFUL SET IMPORTANT BY AUTHORIZED USER
    // ------------------------------------------------------------------
    
    /**
     * @dev testSetImportantSucceedsForAuthorized demonstrates that an authorized user,
     *      once added via addAuthUser, can update the "important" variable.
     *      It verifies the state change by directly reading the storage slot.
     */
    function testSetImportantSucceedsForAuthorized() public {
        // ────────────────────────────────────────────────
        // Step 1: Owner registers authUser.
        // ────────────────────────────────────────────────
        vm.prank(owner);              // Set msg.sender to owner.
        nuts.addAuthUser(authUser);     // Register authUser as an authorized user.
        
        // ────────────────────────────────────────────────
        // Step 2: Authorized user calls setImportant.
        // ────────────────────────────────────────────────
        vm.prank(authUser);           // Set msg.sender to authUser.
        nuts.setImportant(100);       // Update "important" to 100.
        
        // ────────────────────────────────────────────────
        // Step 3: Verification - Read the storage slot directly using vm.load.
        // We assume "important" is stored at slot 0.
        // ────────────────────────────────────────────────
        uint256 result = uint256(vm.load(address(nuts), bytes32(uint256(0))));
        assertEq(result, 100, "Important not set correctly by authorized user");
    }

    // ------------------------------------------------------------------
    //  TEST CASE: FUNCTIONALITY RESTORED AFTER UNPAUSE
    // ------------------------------------------------------------------
    
    /**
     * @dev testUnpauseRestoresAction checks that after pausing and then unpausing the contract,
     *      an authorized user can resume calling setImportant().
     */
    function testUnpauseRestoresAction() public {
        // ────────────────────────────────────────────────
        // Add authUser to the authorized list.
        // ────────────────────────────────────────────────
        vm.prank(owner);              // Set msg.sender to owner.
        nuts.addAuthUser(authUser);     // Register authUser.
        
        // ────────────────────────────────────────────────
        // Pause the contract to disable state-changing actions.
        // ────────────────────────────────────────────────
        vm.prank(owner);              // Set msg.sender to owner.
        nuts.pause();                 // Pause the contract.
        
        // ────────────────────────────────────────────────
        // Unpause the contract to restore functionality.
        // ────────────────────────────────────────────────
        vm.prank(owner);              // Set msg.sender to owner.
        nuts.unpause();               // Unpause the contract.
        
        // ────────────────────────────────────────────────
        // Now, authUser should be able to update the important value.
        // ────────────────────────────────────────────────
        vm.prank(authUser);           // Set msg.sender to authUser.
        nuts.setImportant(300);       // Update "important" to 300.
        
        // ────────────────────────────────────────────────
        // Verify that the update has been successfully applied.
        // ────────────────────────────────────────────────
        uint256 result = uint256(vm.load(address(nuts), bytes32(uint256(0))));
        assertEq(result, 300, "Important not set correctly after unpause");
    }

    // ------------------------------------------------------------------
    //  TEST CASE: VERIFY CORRECT EVENT EMISSION
    // ------------------------------------------------------------------
    
    /**
     * @dev testAddAuthUserEventEmitted checks that the UserAuthorized event is emitted
     *      when the owner adds an authorized user.
     */
    function testAddAuthUserEventEmitted() public {
        // ────────────────────────────────────────────────
        // Expectation: The event should be emitted with authUser as the parameter.
        // ────────────────────────────────────────────────
        vm.prank(owner);              // Set msg.sender to owner.
        vm.expectEmit(true, false, false, false);   // Only check the first indexed parameter.
        emit UserAuthorized(authUser);                // Emit the expected event for verification.
        // ────────────────────────────────────────────────
        // Trigger the actual function call which should emit the event.
        // ────────────────────────────────────────────────
        nuts.addAuthUser(authUser);
    }
}
