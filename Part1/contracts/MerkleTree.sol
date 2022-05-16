//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        uint n = 3;
        for (uint i = 0; i < 2**n; i++) {
            hashes.push(0);
        }

        uint shift = 0;
        for (uint j = n-1; j >= 0; j--) {
            for (uint i = 0; i < 2**j; i++) {
                hashes.push(PoseidonT3.poseidon([hashes[i+shift], hashes[i+1+shift]]));
            }
            shift += 2**(j+1);

            if (j == 0) {
                break;
            }
        }
        root = hashes[shift];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;
        index++;

        uint shift = 0;
        uint n = 3;
        uint tmp_idx = index - 1;

        for (uint j = n-1; j >= 0; j--) {
            for (uint i = 0; i < 2**j; i++) {
                if (tmp_idx == i || tmp_idx == i+1) {
                    hashes[i+shift+2**(j+1)] = PoseidonT3.poseidon([hashes[i+shift], hashes[i+1+shift]]);
                    tmp_idx /= 2;
                    break;
                }
            }
            shift += 2**(j+1);
            if (j == 0) {
                break;
            }
        }
        root = hashes[shift];
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return (input[0] == root) && verifyProof(a, b, c, input);
    }
}
