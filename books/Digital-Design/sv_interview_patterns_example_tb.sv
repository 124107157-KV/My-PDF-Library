`timescale 1ns/1ps

module sv_interview_patterns_example_tb;
  import sv_interview_patterns_pkg::*;

  initial begin
    int a[];
    int pref[];
    int idx0, idx1;
    bit found;
    int maxwin;
    int ans2d[$][$];
    int out[$];
    longint memo[int];

    a = '{1, 2, 3, 4, 6, 8, 9};
    found = two_sum_sorted(a, 10, idx0, idx1);
    $display("two_sum_sorted found=%0d idx0=%0d idx1=%0d", found, idx0, idx1);

    build_prefix_sum(a, pref);
    $display("range_sum[1..3]=%0d", range_sum(pref, 1, 3));

    maxwin = max_sum_fixed_window(a, 3);
    $display("max_sum_fixed_window=%0d", maxwin);

    all_subsets(a, ans2d);
    $display("subset_count=%0d", ans2d.size());

    tree_preorder(null, out);
    $display("fib_top_down(10)=%0d", fib_top_down(10, memo));

    $finish;
  end
endmodule
