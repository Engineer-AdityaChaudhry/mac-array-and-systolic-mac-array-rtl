module mac_cell #(
    parameter int DATA_W = 8,
    parameter int ACC_W  = 32,
    parameter int ACT_W  = 16
)(
    input  logic clk,
    input  logic rst,
    input  logic en,
    input  logic signed [DATA_W-1:0] a,
    input  logic signed [DATA_W-1:0] b,

    output logic signed [ACC_W-1:0]      acc_out,
    output logic signed [2*DATA_W-1:0]   mult_out,
    output logic [ACT_W-1:0]             activity_count
);

    logic signed [2*DATA_W-1:0] mult;
    logic signed [ACC_W-1:0]    mult_ext;
    logic signed [ACC_W-1:0]    acc_next;

    // Combinational multiply
    always_comb begin
        mult     = a * b;
        mult_ext = $signed(mult);
        acc_next = acc_out + mult_ext;
    end

    // Sequential accumulation and activity counting
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            acc_out        <= '0;
            activity_count <= '0;
        end
        else begin
            if (en) begin
                acc_out <= acc_next;

                // Count valid MAC operations as activity
                if ((a != '0) || (b != '0))
                    activity_count <= activity_count + 1'b1;
            end
        end
    end

    // Expose multiplier result for visibility/debug/VCD analysis
    assign mult_out = mult;

endmodule