//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[15] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        for(uint i = 0; i < 15; i++){
            hashes[i] = 0;
        }
        for(uint level = 2; level>0; level--){
            for(uint j = 0; j < 2**level; j++){
                hashes[j + 2**(level + 1)]  = PoseidonT3.poseidon([hashes[2*j],hashes[2*j+1]]);
            }
        }
        
        root = hashes[14];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        uint256 leaf1;
        uint256 leaf2;
        uint curIndex = index;
        hashes[index] = hashedLeaf;
        for (uint level = 2; level > 0; level --){
            if (curIndex % 2 == 0){
                leaf1 = hashes[curIndex];
                leaf2 = hashes[curIndex + 1];
            } else {
                leaf1 = hashes[curIndex - 1];
                leaf2 = hashes[curIndex];
            }
            curIndex = curIndex/2 + 2**(level + 1);
            hashes[curIndex] = PoseidonT3.poseidon([leaf1,leaf2]);
            
        }
        index += 1;
        root = hashes[14];
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return Verifier.verifyProof(a, b, c, input);
    }
}
