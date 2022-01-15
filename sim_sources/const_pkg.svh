    `define CRDNT    12
    `define ADC_bit  4
    
    typedef struct {
        logic [`CRDNT-1:0] h_crdnt; // x
        logic [`CRDNT-1:0] v_crdnt; // y
    }crdnt;
