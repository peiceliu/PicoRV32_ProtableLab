    //checksum function
    function    [31:0]  checksum_adder(
        input       [31:0]  dataina,
        input       [31:0]  datainb
    );
          
        begin
            checksum_adder = dataina + datainb;
        end
        
    endfunction
    
    function    [31:0]  checksum_out(
        input       [31:0]  dataina
    );
        begin
            checksum_out = dataina[15:0]+dataina[31:16];
        end
        
    endfunction