// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Digital Asset Registry
 * @dev Allows users to register digital assets with metadata and verify asset details
 */
contract DigitalAssetRegistry {
    // Structure to store asset information
    struct Asset {
        string assetHash;        // Unique identifier/hash of the digital asset
        address ownerAddress;    // Address of the asset owner
        uint256 registrationTime; // Timestamp when the asset was registered
        string metadata;         // Additional metadata about the asset (optional)
    }
    
    // Mapping from asset hash to Asset struct
    mapping(string => Asset) private assets;
    
    // Array to store all asset hashes for enumeration (if needed)
    string[] private assetHashes;
    
    // Events for logging actions
    event AssetRegistered(string assetHash, address indexed owner, uint256 timestamp);
    event OwnershipTransferred(string assetHash, address indexed previousOwner, address indexed newOwner);
    
    /**
     * @dev Register a new digital asset
     * @param _assetHash Unique hash/identifier of the asset
     * @param _metadata Additional information about the asset
     */
    function registerAsset(string memory _assetHash, string memory _metadata) public {
        // Ensure asset hash is not empty
        require(bytes(_assetHash).length > 0, "Asset hash cannot be empty");
        
        // Ensure asset does not already exist
        require(assets[_assetHash].ownerAddress == address(0), "Asset already registered");
        
        // Create and store the asset
        assets[_assetHash] = Asset({
            assetHash: _assetHash,
            ownerAddress: msg.sender,
            registrationTime: block.timestamp,
            metadata: _metadata
        });
        
        // Add asset hash to array for enumeration
        assetHashes.push(_assetHash);
        
        // Emit event
        emit AssetRegistered(_assetHash, msg.sender, block.timestamp);
    }
    
    function verifyAsset(string memory _assetHash) public view returns (
        string memory hash,
        address owner,
        uint256 registrationTime,
        string memory metadata
    ) {
        // Ensure asset exists
        require(assets[_assetHash].ownerAddress != address(0), "Asset not found");
        
        Asset memory asset = assets[_assetHash];
        return (
            asset.assetHash,
            asset.ownerAddress,
            asset.registrationTime,
            asset.metadata
        );
    }
    
    /**
     * @dev Transfer ownership of an asset to another address
     * @param _assetHash Hash of the asset to transfer
     * @param _newOwner Address of the new owner
     */
    function transferOwnership(string memory _assetHash, address _newOwner) public {
        // Ensure asset exists
        require(assets[_assetHash].ownerAddress != address(0), "Asset not found");
        
        // Ensure sender is the current owner
        require(assets[_assetHash].ownerAddress == msg.sender, "Only the owner can transfer ownership");
        
        // Ensure new owner is not the zero address
        require(_newOwner != address(0), "New owner cannot be the zero address");
        
        // Store the previous owner for the event
        address previousOwner = assets[_assetHash].ownerAddress;
        
        // Update the owner
        assets[_assetHash].ownerAddress = _newOwner;
        
        // Emit event
        emit OwnershipTransferred(_assetHash, previousOwner, _newOwner);
    }
    
    /**
     * @dev Get the total number of registered assets
     * @return The count of registered assets
     */
    function getAssetCount() public view returns (uint256) {
        return assetHashes.length;
    }
    
    /**
     * @dev Check if an asset exists
     * @param _assetHash Hash of the asset to check
     * @return Boolean indicating whether the asset exists
     */
    function assetExists(string memory _assetHash) public view returns (bool) {
        return assets[_assetHash].ownerAddress != address(0);
    }
    
    /**
     * @dev Get asset hash by index (for enumeration)
     * @param _index Index in the asset array
     * @return The asset hash at the specified index
     */
    function getAssetHashAtIndex(uint256 _index) public view returns (string memory) {
        require(_index < assetHashes.length, "Index out of bounds");
        return assetHashes[_index];
    }
}
