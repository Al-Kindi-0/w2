pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";


template hashLayer(depth){
    var numElem = 1 << (depth);
    signal input ins[numElem*2];
    signal output outs[numElem];
    
    component hasher[numElem];
    for(var i = 0; i < numElem; i++){
        hasher[i] = Poseidon(2);
        hasher[i].inputs[0] <== ins[2*i];
        hasher[i].inputs[1] <== ins[2*i + 1];
        outs[i] <== hasher[i].out;
    }
}

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;
    component hashlayer[n];
    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    for(var i = n - 1; i >= 0; i--){
        hashlayer[i] = hashLayer(1<<n);
        for(var j = 0; j < (1<<(n+1)); j++){
            hashlayer[i].ins[j] <== (i == n)? leaves[j] : hashlayer[i + 1].outs[j];
        }
    }

    root <== (n > 0) ? hashlayer[0].outs[0] : leaves[0];
}

template mux2(){
    signal input i;
    signal input A;
    signal input B;
    signal output A_out;
    signal output B_out;

    signal tmp;
    tmp <== (B - A)*i;
    A_out <== tmp + A;
    B_out <== -tmp + B;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    component multiplexors[n];
    component hasher[n];

    for(var i = 0; i < n; i++){
        multiplexors[i] = mux2();
        multiplexors[i].A <== (i==0) ? leaf : hasher[i-1].out;
        multiplexors[i].B <== path_elements[i];
        multiplexors[i].i <== path_index[i];

        hasher[i] = Poseidon(2);
        hasher[i].inputs[0] <== multiplexors[i].A_out;
        hasher[i].inputs[1] <== multiplexors[i].B_out;

    }

    root <== hasher[n-1].out;
}