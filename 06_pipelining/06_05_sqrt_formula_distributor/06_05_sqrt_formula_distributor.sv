module sqrt_formula_distributor
# (
    parameter formula = 1,
              impl    = 1
)
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output logic res_vld,
    output logic [31:0] res
);

    localparam n_workers = 50;

    logic worker_arg_vld [n_workers];
    logic worker_res_vld [n_workers];
    logic [31:0] worker_res[n_workers];
    logic [31:0] worker_a_reg [n_workers];
    logic [31:0] worker_b_reg [n_workers];
    logic [31:0] worker_c_reg [n_workers];
    logic [31:0] worker_a [n_workers];
    logic [31:0] worker_b [n_workers];
    logic [31:0] worker_c [n_workers];
    int unsigned wr_ptr;

    always_ff @(posedge clk) begin
        if (rst)
            wr_ptr <= 0;
        else if (arg_vld)
            wr_ptr <= (wr_ptr == n_workers - 1) ? 0 : wr_ptr + 1;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < n_workers; i++) begin
                worker_a_reg[i] <= '0;
                worker_b_reg[i] <= '0;
                worker_c_reg[i] <= '0;
            end
        end else if (arg_vld) begin
            worker_a_reg[wr_ptr] <= a;
            worker_b_reg[wr_ptr] <= b;
            worker_c_reg[wr_ptr] <= c;
        end
    end

    always_comb begin
        for (int i = 0; i < n_workers; i++) begin
            worker_arg_vld[i] = arg_vld && (wr_ptr == i);
            worker_a[i] = (arg_vld && wr_ptr == i) ? a : worker_a_reg[i];
            worker_b[i] = (arg_vld && wr_ptr == i) ? b : worker_b_reg[i];
            worker_c[i] = (arg_vld && wr_ptr == i) ? c : worker_c_reg[i];
        end
    end

    generate
        for (genvar i = 0; i < n_workers; i++) begin : gen_workers
            if (formula == 1 && impl == 1) begin : gen_f1_i1
                formula_1_impl_1_top worker (
                    .clk(clk),
                    .rst(rst),
                    .arg_vld(worker_arg_vld[i]),
                    .a(worker_a[i]),
                    .b(worker_b[i]),
                    .c(worker_c [i]),
                    .res_vld(worker_res_vld [i]),
                    .res(worker_res[i])
                );
            end
            else if (formula == 1 && impl == 2) begin : gen_f1_i2
                formula_1_impl_2_top worker (
                    .clk(clk),
                    .rst(rst),
                    .arg_vld (worker_arg_vld [i]),
                    .a(worker_a[i]),
                    .b (worker_b[i]),
                    .c (worker_c[i]),
                    .res_vld (worker_res_vld[i]),
                    .res(worker_res[i])
                );
            end
            else if (formula == 2) begin : gen_f2
                formula_2_top worker (
                    .clk(clk),
                    .rst(rst),
                    .arg_vld(worker_arg_vld [i]),
                    .a(worker_a[i]),
                    .b(worker_b[i]),
                    .c(worker_c[i]),
                    .res_vld(worker_res_vld[i]),
                    .res(worker_res[i])
                );
            end
        end
    endgenerate

    always_comb begin
        res_vld = 1'b0;
        res     = '0;
        for (int i = 0; i < n_workers; i++) begin
            if (worker_res_vld[i]) begin
                res_vld = 1'b1;
                res = worker_res[i];
            end
        end
    end

    // Task:
    //
    // Implement a module that will calculate formula 1 or formula 2
    // based on the parameter values. The module must be pipelined.
    // It should be able to accept new triple of arguments a, b, c arriving
    // at every clock cycle.
    //
    // The idea of the task is to implement hardware task distributor,
    // that will accept triplet of the arguments and assign the task
    // of the calculation formula 1 or formula 2 with these arguments
    // to the free FSM-based internal module.
    //
    // The first step to solve the task is to fill 03_04 and 03_05 files.
    //
    // Note 1:
    // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
    // or simply assumed to be equal 50 clock cycles.
    //
    // Note 2:
    // The task assumes idealized distributor (with 50 internal computational blocks),
    // because in practice engineers rarely use more than 10 modules at ones.
    // Usually people use 3-5 blocks and utilize stall in case of high load.
    //
    // Hint:
    // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
    // or "formula_2_top" modules to achieve desired performance.


endmodule
