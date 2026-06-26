module mac_array #(
    parameter int DATA_W = 8,
    parameter int ACC_W  = 32,
    parameter int ACT_W  = 16,
    parameter int N      = 2
)(
    input  logic clk,
    input  logic rst,

    input  logic signed [DATA_W-1:0] a_in [N][N],
    input  logic signed [DATA_W-1:0] b_in [N][N],
    input  logic                     en_in [N][N],

    output logic signed [ACC_W-1:0]  acc_out [N][N],
    output logic signed [2*DATA_W-1:0] mult_out [N][N],
    output logic [ACT_W-1:0]         activity_count [N][N]
);

    genvar i, j;

    generate
        for (i = 0; i < N; i++) begin : ROW
            for (j = 0; j < N; j++) begin : COL
                mac_cell #(
                    .DATA_W(DATA_W),
                    .ACC_W (ACC_W),
                    .ACT_W (ACT_W)
                ) u_mac (
                    .clk           (clk),
                    .rst           (rst),
                    .en            (en_in[i][j]),
                    .a             (a_in[i][j]),
                    .b             (b_in[i][j]),
                    .acc_out       (acc_out[i][j]),
                    .mult_out      (mult_out[i][j]),
                    .activity_count(activity_count[i][j])
                );
            end
        end
    endgenerate

endmodule