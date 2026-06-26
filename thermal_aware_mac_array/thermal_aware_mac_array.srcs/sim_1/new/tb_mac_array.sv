`timescale 1ns/1ps

module tb_mac_array;

    parameter int N        = 16;   // Use 2, 4, 8, or 16
    parameter int DATA_W   = 8;
    parameter int ACC_W    = 32;
    parameter int ACT_W    = 16;
    parameter int WORKLOAD = 2;   // 0=uniform, 1=hotspot, 2=checkerboard

    logic clk;
    logic rst;

    logic signed [DATA_W-1:0] a_in [N][N];
    logic signed [DATA_W-1:0] b_in [N][N];
    logic                     en_in [N][N];

    logic signed [ACC_W-1:0]    acc_out [N][N];
    logic signed [2*DATA_W-1:0] mult_out [N][N];
    logic [ACT_W-1:0]           activity_count [N][N];

    logic [1:0] workload_id;     // 0=uniform, 1=hotspot, 2=checkerboard

    integer i, j, c;
    integer hot_i, hot_j;
    integer HOT_N;

    mac_array #(
        .N(N),
        .DATA_W(DATA_W),
        .ACC_W(ACC_W),
        .ACT_W(ACT_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .a_in(a_in),
        .b_in(b_in),
        .en_in(en_in),
        .acc_out(acc_out),
        .mult_out(mult_out),
        .activity_count(activity_count)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    task clear_all;
        begin
            for (i = 0; i < N; i = i + 1) begin
                for (j = 0; j < N; j = j + 1) begin
                    a_in[i][j]  = '0;
                    b_in[i][j]  = '0;
                    en_in[i][j] = 1'b0;
                end
            end
        end
    endtask

    task reset_dut;
        begin
            rst = 1'b1;
            repeat (3) @(posedge clk);
            rst = 1'b0;
        end
    endtask

    task uniform_load(input integer cycles);
        begin
            workload_id = 2'd0;
            for (c = 0; c < cycles; c = c + 1) begin
                for (i = 0; i < N; i = i + 1) begin
                    for (j = 0; j < N; j = j + 1) begin
                        a_in[i][j]  = i + j + 1;
                        b_in[i][j]  = i + 1;
                        en_in[i][j] = 1'b1;
                    end
                end
                @(posedge clk);
            end
        end
    endtask

    task hotspot_load(input integer cycles);
        begin
            workload_id = 2'd1;

            HOT_N = N / 2;
            if (HOT_N < 1)
                HOT_N = 1;

            for (c = 0; c < cycles; c = c + 1) begin
                clear_all();

                for (hot_i = 0; hot_i < HOT_N; hot_i = hot_i + 1) begin
                    for (hot_j = 0; hot_j < HOT_N; hot_j = hot_j + 1) begin
                        a_in[hot_i][hot_j]  = hot_i + hot_j + 2;
                        b_in[hot_i][hot_j]  = hot_i + 2;
                        en_in[hot_i][hot_j] = 1'b1;
                    end
                end

                @(posedge clk);
            end
        end
    endtask

    task checkerboard_load(input integer cycles);
        begin
            workload_id = 2'd2;

            for (c = 0; c < cycles; c = c + 1) begin
                for (i = 0; i < N; i = i + 1) begin
                    for (j = 0; j < N; j = j + 1) begin
                        a_in[i][j]  = i + 2;
                        b_in[i][j]  = j + 3;
                        en_in[i][j] = ((i + j) % 2 == 0);
                    end
                end
                @(posedge clk);
            end
        end
    endtask

    task print_activity_counts;
        begin
            $display("Activity Counters for N=%0d, workload_id=%0d", N, workload_id);
            for (i = 0; i < N; i = i + 1) begin
                for (j = 0; j < N; j = j + 1) begin
                    $write("%0d ", activity_count[i][j]);
                end
                $write("\n");
            end
        end
    endtask

    initial begin
        clk         = 1'b0;
        rst         = 1'b1;
        workload_id = 2'd0;

        clear_all();

        // Select VCD filename based on workload
        case (WORKLOAD)
            0: $dumpfile("mac_array_uniform_16x16.vcd");
            1: $dumpfile("mac_array_hotspot_16x16.vcd");
            2: $dumpfile("mac_array_checkerboard_16x16.vcd");
            default: $dumpfile("mac_array_unknown.vcd");
        endcase

        

        reset_dut();
        $dumpvars(0, tb_mac_array);
        $display("==========================================");
        $display("Starting STANDARD MAC array simulation");
        $display("N = %0d, WORKLOAD = %0d", N, WORKLOAD);
        $display("==========================================");

        case (WORKLOAD)
            0: begin
                $display("Starting uniform workload");
                uniform_load(10);
            end

            1: begin
                $display("Starting hotspot workload");
                hotspot_load(10);
            end

            2: begin
                $display("Starting checkerboard workload");
                checkerboard_load(10);
            end

            default: begin
                $display("ERROR: Unsupported WORKLOAD value = %0d", WORKLOAD);
            end
        endcase

        print_activity_counts();

        clear_all();
        repeat (5) @(posedge clk);

        $display("==========================================");
        $display("Simulation completed for STANDARD MAC array");
        $display("N = %0d, WORKLOAD = %0d", N, WORKLOAD);
        $display("==========================================");

        $dumpoff;
        $finish;
    end

endmodule