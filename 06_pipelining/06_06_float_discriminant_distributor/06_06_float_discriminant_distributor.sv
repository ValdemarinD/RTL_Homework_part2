module float_discriminant_distributor #(
    parameter N_workers = 70
    )(
    input                           clk,
    input                           rst,

    input                           arg_vld,
    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);

    logic worker_vld [N_workers];
    logic [FLEN:0] worker_a [N_workers];
    logic [FLEN:0] worker_b [N_workers];
    logic [FLEN:0] worker_c [N_workers];
    logic worker_res_vld [N_workers];
    logic [FLEN:0] worker_res [N_workers];
    logic worker_res_negative [N_workers];
    logic worker_err [N_workers];
    logic worker_busy [N_workers];
    
    logic found;
    integer selected_worker;

    always_comb begin
        found = 1'b0;
        selected_worker = -1;

        for(int i = 0 ; i < N_workers; i++) begin
            if(!worker_busy[i] && !found) begin
                found = 1'b1;
                selected_worker = i;
            end
        end
    end

    always_comb begin
        for(int i = 0; i < N_workers; i++) begin
            worker_vld[i] = 1'b0;
            worker_a[i] = '0;
            worker_b[i] = '0;
            worker_c[i] = '0;
        end
        if (arg_vld && found) begin
            worker_vld[selected_worker] = 1'b1;
            worker_a[selected_worker] = a;
            worker_b[selected_worker] = b;
            worker_c[selected_worker] = c;
        end
    end

    generate 
        for (genvar i = 0; i < N_workers; i++) begin : gen_wowrkers

            float_discriminant worker
             (
                .clk(clk),
                .rst(rst),
                .arg_vld(worker_vld[i]),
                .a(worker_a[i]),
                .b(worker_b[i]),
                .c(worker_c[i]),
                .res_vld(worker_res_vld[i]),
                .res(worker_res[i]),
                .res_negative(worker_res_negative[i]),
                .err(worker_err[i]),
                .busy(worker_busy[i])
            );

        end
    endgenerate

    always_comb begin 
        res_vld = 1'b0;
        res = '0;
        res_negative = 1'b0;
        err = 1'b0;

        for (int i = 0; i < N_workers; i++) begin
            if(worker_res_vld[i]) begin
                res_vld = 1'b1;
                res = worker_res[i];
                res_negative = worker_res_negative[i];
                err = worker_err[i];            
            end
        end
    end

    always_comb begin
        busy = 1'b1;
        for (int i = 0; i < N_workers; i++) begin
            if(!worker_busy[i])
                busy = 1'b0;
        end
    end




    // Task:
    //
    // Implement a module that will calculate the discriminant based
    // on the triplet of input number a, b, c. The module must be pipelined.
    // It should be able to accept a new triple of arguments on each clock cycle
    // and also, after some time, provide the result on each clock cycle.
    // The idea of the task is similar to the task 04_11. The main difference is
    // in the underlying module 03_08 instead of formula modules.
    //
    // Note 1:
    // Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
    //
    // Note 2:
    // Latency of the module "float_discriminant" should be clarified from the waveform.


endmodule
