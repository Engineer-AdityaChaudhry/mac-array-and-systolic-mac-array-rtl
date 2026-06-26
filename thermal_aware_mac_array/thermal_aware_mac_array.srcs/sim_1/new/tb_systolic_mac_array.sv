`timescale 1ns/1ps

module tb_systolic_mac_array;

    parameter int N        = 16;   // Use 2, 4, 8, or 16
    parameter int DATA_W   = 8;
    parameter int ACC_W    = 32;
    parameter int ACT_W    = 16;
    parameter int WORKLOAD = 2;   // 0=uniform, 1=hotspot, 2=checkerboard

    logic clk;
    logic rst;
    logic en;

    logic signed [DATA_W-1:0] a_left [N];
    logic signed [DATA_W-1:0] b_top  [N];

    logic signed [ACC_W-1:0]    acc_out [N][N];
    logic signed [2*DATA_W-1:0] mult_out [N][N];
    logic [ACT_W-1:0]           activity_count [N][N];

    logic [1:0] workload_id;   // 0=uniform, 1=hotspot, 2=checkerboard

    integer i, c;
    integer HOT_N;

    systolic_mac_array #(
        .N(N),
        .DATA_W(DATA_W),
        .ACC_W(ACC_W),
        .ACT_W(ACT_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .a_left(a_left),
        .b_top(b_top),
        .acc_out(acc_out),
        .mult_out(mult_out),
        .activity_count(activity_count)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    task clear_inputs;
        begin
            for (i = 0; i < N; i = i + 1) begin
                a_left[i] = '0;
                b_top[i]  = '0;
            end
            en = 1'b0;
        end
    endtask

    task reset_dut;
        begin
            rst = 1'b1;
            en  = 1'b0;
            repeat (3) @(posedge clk);
            rst = 1'b0;
        end
    endtask

    // ----------------------------------
    // Workload 0: Uniform stream
    // All rows/columns inject data every cycle
    // ----------------------------------
    task uniform_stream(input integer cycles);
        begin
            workload_id = 2'd0;
            en = 1'b1;

            for (c = 0; c < cycles; c = c + 1) begin
                for (i = 0; i < N; i = i + 1) begin
                    a_left[i] = i + c + 1;
                    b_top[i]  = i + c + 2;
                end
                @(posedge clk);
            end

            en = 1'b0;
        end
    endtask

    // ----------------------------------
    // Workload 1: Hotspot stream
    // Only a subset of rows/cols inject data
    // ----------------------------------
    task hotspot_stream(input integer cycles);
        begin
            workload_id = 2'd1;
            en = 1'b1;

            HOT_N = N / 2;
            if (HOT_N < 1)
                HOT_N = 1;

            for (c = 0; c < cycles; c = c + 1) begin
                clear_inputs();
                en = 1'b1;

                for (i = 0; i < HOT_N; i = i + 1) begin
                    a_left[i] = i + c + 2;
                    b_top[i]  = i + c + 3;
                end

                @(posedge clk);
            end

            en = 1'b0;
        end
    endtask

    // ----------------------------------
    // Workload 2: Checkerboard / staggered stream
    // Alternate boundary injection pattern over time
    // ----------------------------------
    task checkerboard_stream(input integer cycles);
        begin
            workload_id = 2'd2;
            en = 1'b1;

            for (c = 0; c < cycles; c = c + 1) begin
                clear_inputs();
                en = 1'b1;

                for (i = 0; i < N; i = i + 1) begin
                    if (((i + c) % 2) == 0) begin
                        a_left[i] = i + c + 1;
                        b_top[i]  = i + c + 2;
                    end
                end

                @(posedge clk);
            end

            en = 1'b0;
        end
    endtask

    task print_activity_counts;
        integer r, col;
        begin
            $display("Activity Counters for N=%0d, workload_id=%0d", N, workload_id);
            for (r = 0; r < N; r = r + 1) begin
                for (col = 0; col < N; col = col + 1) begin
                    $write("%0d ", activity_count[r][col]);
                end
                $write("\n");
            end
        end
    endtask

    initial begin
        clk         = 1'b0;
        rst         = 1'b1;
        en          = 1'b0;
        workload_id = 2'd0;

        clear_inputs();

        // Select VCD filename based on workload
        case (WORKLOAD)
            0: $dumpfile("systolic_mac_array_uniform_16x16.vcd");
            1: $dumpfile("systolic_mac_array_hotspot_16x16.vcd");
            2: $dumpfile("systolic_mac_array_checkerboard_16x16.vcd");
            default: $dumpfile("systolic_mac_array_unknown.vcd");
        endcase

        reset_dut();
        $dumpvars(0, tb_systolic_mac_array);

        $display("==========================================");
        $display("Starting SYSTOLIC MAC array simulation");
        $display("N = %0d, WORKLOAD = %0d", N, WORKLOAD);
        $display("==========================================");

        case (WORKLOAD)
            0: begin
                $display("Starting uniform systolic stream");
                uniform_stream(12);
            end

            1: begin
                $display("Starting hotspot systolic stream");
                hotspot_stream(12);
            end

            2: begin
                $display("Starting checkerboard systolic stream");
                checkerboard_stream(12);
            end

            default: begin
                $display("ERROR: Unsupported WORKLOAD value = %0d", WORKLOAD);
            end
        endcase

        // Let wave propagate and settle through array
        clear_inputs();
        en = 1'b1;
        repeat (N + 4) @(posedge clk);
        en = 1'b0;

        print_activity_counts();

        $display("==========================================");
        $display("Simulation completed for SYSTOLIC MAC array");
        $display("N = %0d, WORKLOAD = %0d", N, WORKLOAD);
        $display("==========================================");

        $dumpoff;
        $finish;
    end

endmodule