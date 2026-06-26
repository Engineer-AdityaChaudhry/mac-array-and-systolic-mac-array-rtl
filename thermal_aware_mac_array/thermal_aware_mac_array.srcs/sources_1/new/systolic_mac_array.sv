module systolic_mac_array #(
    parameter int DATA_W = 8,
    parameter int ACC_W  = 32,
    parameter int ACT_W  = 16,
    parameter int N      = 2
)(
    input  logic clk,
    input  logic rst,
    input  logic en,

    input  logic signed [DATA_W-1:0] a_left [N],
    input  logic signed [DATA_W-1:0] b_top  [N],

    output logic signed [ACC_W-1:0]      acc_out [N][N],
    output logic signed [2*DATA_W-1:0]   mult_out [N][N],
    output logic [ACT_W-1:0]             activity_count [N][N]
);

    // Internal systolic interconnect
    logic signed [DATA_W-1:0] a_pipe [N][N];
    logic signed [DATA_W-1:0] b_pipe [N][N];

    genvar i, j;

    generate
        for (i = 0; i < N; i++) begin : ROW
            for (j = 0; j < N; j++) begin : COL

                logic signed [DATA_W-1:0] a_in_cell;
                logic signed [DATA_W-1:0] b_in_cell;

                // Left boundary injection for a
                if (j == 0) begin : A_LEFT_BOUNDARY
                    assign a_in_cell = a_left[i];
                end
                else begin : A_INTERNAL
                    assign a_in_cell = a_pipe[i][j-1];
                end

                // Top boundary injection for b
                if (i == 0) begin : B_TOP_BOUNDARY
                    assign b_in_cell = b_top[j];
                end
                else begin : B_INTERNAL
                    assign b_in_cell = b_pipe[i-1][j];
                end

                systolic_mac_cell #(
                    .DATA_W(DATA_W),
                    .ACC_W (ACC_W),
                    .ACT_W (ACT_W)
                ) u_cell (
                    .clk           (clk),
                    .rst           (rst),
                    .en            (en),

                    .a_in          (a_in_cell),
                    .b_in          (b_in_cell),

                    .a_out         (a_pipe[i][j]),
                    .b_out         (b_pipe[i][j]),

                    .acc_out       (acc_out[i][j]),
                    .mult_out      (mult_out[i][j]),
                    .activity_count(activity_count[i][j])
                );

            end
        end
    endgenerate

endmodule