pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves

    signal hashed[2**n-1];
    component poseidons[2**n-1];
    for (var i = 0; i < 2**(n-1); i++) {
        poseidons[i] = Poseidon(2);
        poseidons[i].inputs[0] <== leaves[i];
        poseidons[i].inputs[1] <== leaves[i+1];
        hashed[i] <== poseidons[i].out;
    }

    var p = 2**(n-1); // poseidon pointer
    var hs = 0; // hash shifter
    for (var j = n-2; j >= 0; j--) {
        for (var i = 0; j < 2**j; i++) {
            poseidons[p] = Poseidon(2);
            poseidons[p].inputs[0] <== hashed[i + hs];
            poseidons[p].inputs[1] <== hashed[i+1 + hs];
            hashed[p] <== poseidons[i].out;
            p++;
        }
        hs = p - 2**j;
    }
    root <== hashed[hs];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path

    signal midls[n+1];
    midls[0] <== leaf;
    component poseidons[n];
    component switcher[n];

    for (var i = 0; i < n; i++) {
        poseidons[i] = Poseidon(2);
        switcher[i] = Switcher();

        switcher[i].sel <== path_index[i];
        switcher[i].L <== midls[i];
        switcher[i].R <== path_elements[i];

        poseidons[i].inputs[0] <== switcher[i].outL;
        poseidons[i].inputs[1] <== switcher[i].outR;

        midls[i+1] <== poseidons[i].out;
    }
    root <== midls[n];
}