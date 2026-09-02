`timescale 1ns / 1ps

module top_tb;
    reg clk;
    reg rst;
    integer output_file;

    wire out;
    wire done;

    top uut (
        .clk(clk),
        .rst(rst),
        .out(out),
        .done(done)
    );

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        output_file = $fopen("test.txt", "w");

        if (output_file == 0) begin
            $fatal(1, "Unable to open test.txt");
        end

        #10;
        rst = 1'b0;
    end

    always #1 clk = ~clk;

    always @(posedge clk) begin
        if (!rst) begin
            $fwrite(output_file, "%0d\n", out);

            if (done) begin
                $fclose(output_file);
                $display("Detection stream complete.");
                $finish;
            end
        end
    end

    // Guard against an accidental infinite simulation.
    initial begin
        #50000000;
        $fatal(1, "Simulation timeout");
    end
endmodule
