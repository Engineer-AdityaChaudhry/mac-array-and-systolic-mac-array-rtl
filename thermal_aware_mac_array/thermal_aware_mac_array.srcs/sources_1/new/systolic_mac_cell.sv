module systolic_mac_cell #(
    parameter int DATA_W = 8,
    parameter int ACC_W  = 32,
    parameter int ACT_W  = 16
)(
    input  logic clk,
    input  logic rst,
    input  logic en,

    input  logic signed [DATA_W-1:0] a_in,
    input  logic signed [DATA_W-1:0] b_in,

    output logic signed [DATA_W-1:0] a_out,
    output logic signed [DATA_W-1:0] b_out,

    output logic signed [ACC_W-1:0]      acc_out,
    output logic signed [2*DATA_W-1:0]   mult_out,
    output logic [ACT_W-1:0]             activity_count
);

    logic signed [2*DATA_W-1:0] mult;
    logic signed [ACC_W-1:0]    mult_ext;
    logic signed [ACC_W-1:0]    acc_next;

    // Combinational multiply using current inputs
    always_comb begin
        mult     = a_in * b_in;
        mult_ext = $signed(mult);
        acc_next = acc_out + mult_ext;
    end

    // Registered forwarding + accumulation
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            a_out          <= '0;
            b_out          <= '0;
            acc_out        <= '0;
            activity_count <= '0;
        end
        else begin
            if (en) begin
                // Forward inputs to neighboring cells
                a_out <= a_in;
                b_out <= b_in;

                // Accumulate local MAC result
                acc_out <= acc_next;

                // Count active operations
                if ((a_in != '0) || (b_in != '0))
                    activity_count <= activity_count + 1'b1;
            end
        end
    end

    assign mult_out = mult;

endmodule