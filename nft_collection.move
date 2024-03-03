// NFT Collection Module

module NFTCollection {
    // Define the NFT resource
    resource NFT {
        id: u64,
        owner: address,
        metadata: vector<u8>
    }

    // Define the storage for NFTs
    public let NFTs: vector<NFT>;

    // Define the storage for token sales
    public let TokenSales: vector<u64>;

    // Function to mint a new NFT
    public fun mint_nft(metadata: vector<u8>) {
        let new_id = NFTs.size() as u64;
        let new_nft = NFT {
            id: new_id,
            owner: get_txn_sender(),
            metadata: metadata
        };
        move_to(new_nft, &mut NFTs);
    }

    // Function to combine two NFTs into a new NFT
    public fun combine_nfts(nft1_id: u64, nft2_id: u64, new_metadata: vector<u8>) {
        let nft1 = borrow_global_mut(&NFTs[nft1_id as usize]);
        let nft2 = borrow_global_mut(&NFTs[nft2_id as usize]);

        // Ensure the caller is the owner of both NFTs
        assert(nft1.owner == get_txn_sender() && nft2.owner == get_txn_sender(), 101);

        // Create a new NFT by combining metadata
        let new_id = NFTs.size() as u64;
        let new_nft = NFT {
            id: new_id,
            owner: get_txn_sender(),
            metadata: new_metadata
        };
        move_to(new_nft, &mut NFTs);

        // Remove the two old NFTs
        NFTs.swap_remove(nft1_id as usize);
        NFTs.swap_remove(nft2_id as usize);
    }

    // Function to withdraw sales
    public fun withdraw_sales() {
        // Only the collection manager can withdraw sales
        let manager_address = 0x1234567890123456789012345678901234567890; // Replace with actual manager address
        assert(get_txn_sender() == manager_address, 102);

        let mut total_sales: u64 = 0;

        // Sum up all the sales
        for sale_amount in &TokenSales {
            total_sales += *sale_amount;
        }

        // Clear the TokenSales storage
        TokenSales.clear();

        // Transfer the total sales amount to the manager's address
        LibraAccount::withdraw_from_sender(total_sales);
    }
}

