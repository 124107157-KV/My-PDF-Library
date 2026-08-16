// sv_interview_patterns_pkg.sv
// SystemVerilog interview-pattern template library
// Style: simulation/testbench/problem-solving SystemVerilog, not strict synthesizable RTL.
// Use queues, dynamic arrays, associative arrays, strings, recursion, and classes.

package sv_interview_patterns_pkg;

  // ============================================================
  // Common typedefs
  // ============================================================
  typedef int int_q_t[$];

  typedef struct {
    int lo;
    int hi;
  } interval_t;

  typedef struct {
    int key;   // priority / distance / value
    int node;  // payload
  } heap_item_t;

  typedef struct {
    int to;
    int w;
  } edge_t;

  typedef edge_t edge_q_t[$];

  // ============================================================
  // 0) Tiny utilities
  // ============================================================
  task automatic swap_int(ref int a, ref int b);
    int t;
    t = a;
    a = b;
    b = t;
  endtask

  task automatic reverse_range(ref int a[], input int l, input int r);
    while (l < r) begin
      swap_int(a[l], a[r]);
      l++;
      r--;
    end
  endtask

  // ============================================================
  // 1) Two pointers - opposite direction
  // Pattern: sorted array pair search / two-sum sorted
  // Time O(n), space O(1)
  // ============================================================
  function automatic bit two_sum_sorted(
    input  int a[],
    input  int target,
    output int left_idx,
    output int right_idx
  );
    int l, r, sum;
    l = 0;
    r = a.size() - 1;
    left_idx = -1;
    right_idx = -1;

    while (l < r) begin
      sum = a[l] + a[r];
      if (sum == target) begin
        left_idx = l;
        right_idx = r;
        return 1;
      end
      else if (sum < target) l++;
      else r--;
    end
    return 0;
  endfunction

  // ============================================================
  // 2) Two pointers - same direction / compaction
  // Pattern: remove duplicates from sorted array in-place
  // Returns logical new length; elements [0:new_len-1] are valid.
  // ============================================================
  function automatic int remove_duplicates_sorted(ref int a[]);
    int slow, fast;
    if (a.size() == 0) return 0;

    slow = 0;
    for (fast = 1; fast < a.size(); fast++) begin
      if (a[fast] != a[slow]) begin
        slow++;
        a[slow] = a[fast];
      end
    end
    return slow + 1;
  endfunction

  // ============================================================
  // 3) Two pointers - palindrome check
  // Pattern: compare from both ends
  // ============================================================
  function automatic bit is_palindrome_string(input string s);
    int l, r;
    l = 0;
    r = s.len() - 1;
    while (l < r) begin
      if (s[l] != s[r]) return 0;
      l++;
      r--;
    end
    return 1;
  endfunction

  // ============================================================
  // 4) Linked list templates: fast/slow, cycle, reverse, merge
  // ============================================================
  class ListNode;
    int val;
    ListNode next;

    function new(input int v = 0);
      val = v;
      next = null;
    endfunction
  endclass

  function automatic bit linked_list_has_cycle(input ListNode head);
    ListNode slow, fast;
    slow = head;
    fast = head;

    while (fast != null && fast.next != null) begin
      slow = slow.next;
      fast = fast.next.next;
      if (slow == fast) return 1;
    end
    return 0;
  endfunction

  function automatic ListNode linked_list_middle(input ListNode head);
    ListNode slow, fast;
    slow = head;
    fast = head;

    while (fast != null && fast.next != null) begin
      slow = slow.next;
      fast = fast.next.next;
    end
    return slow;
  endfunction

  function automatic ListNode reverse_linked_list(input ListNode head);
    ListNode prev, cur, nxt;
    prev = null;
    cur = head;

    while (cur != null) begin
      nxt = cur.next;
      cur.next = prev;
      prev = cur;
      cur = nxt;
    end
    return prev;
  endfunction

  function automatic ListNode merge_two_sorted_lists(input ListNode a, input ListNode b);
    ListNode dummy, tail;
    dummy = new(0);
    tail = dummy;

    while (a != null && b != null) begin
      if (a.val <= b.val) begin
        tail.next = a;
        a = a.next;
      end
      else begin
        tail.next = b;
        b = b.next;
      end
      tail = tail.next;
    end
    tail.next = (a != null) ? a : b;
    return dummy.next;
  endfunction

  // ============================================================
  // 5) Sliding window - fixed size
  // Pattern: maximum sum of any window of size k
  // ============================================================
  function automatic int max_sum_fixed_window(input int a[], input int k);
    int i, win, best;
    if (k <= 0 || a.size() < k) return 0;

    win = 0;
    for (i = 0; i < k; i++) win += a[i];
    best = win;

    for (i = k; i < a.size(); i++) begin
      win += a[i] - a[i-k];
      if (win > best) best = win;
    end
    return best;
  endfunction

  // ============================================================
  // 6) Sliding window - variable size
  // Pattern: minimum length subarray with sum >= target, positive numbers
  // ============================================================
  function automatic int min_len_subarray_ge_target(input int a[], input int target);
    int l, r, sum, best;
    best = a.size() + 1;
    l = 0;
    sum = 0;

    for (r = 0; r < a.size(); r++) begin
      sum += a[r];
      while (sum >= target) begin
        if ((r - l + 1) < best) best = r - l + 1;
        sum -= a[l];
        l++;
      end
    end
    return (best == a.size() + 1) ? 0 : best;
  endfunction

  // ============================================================
  // 7) Sliding window + hashmap
  // Pattern: longest substring without repeating characters
  // ============================================================
  function automatic int longest_substring_no_repeat(input string s);
    int last[byte];
    int l, r, best;
    byte c;

    l = 0;
    best = 0;
    for (r = 0; r < s.len(); r++) begin
      c = s[r];
      if (last.exists(c) && last[c] >= l) l = last[c] + 1;
      last[c] = r;
      if ((r - l + 1) > best) best = r - l + 1;
    end
    return best;
  endfunction

  // ============================================================
  // 8) Binary search - exact target
  // Pattern: sorted array search
  // ============================================================
  function automatic int binary_search(input int a[], input int target);
    int l, r, m;
    l = 0;
    r = a.size() - 1;

    while (l <= r) begin
      m = l + ((r - l) >> 1);
      if (a[m] == target) return m;
      else if (a[m] < target) l = m + 1;
      else r = m - 1;
    end
    return -1;
  endfunction

  // ============================================================
  // 9) Binary search - lower bound
  // Pattern: first index i where a[i] >= target
  // ============================================================
  function automatic int lower_bound(input int a[], input int target);
    int l, r, m;
    l = 0;
    r = a.size();

    while (l < r) begin
      m = l + ((r - l) >> 1);
      if (a[m] < target) l = m + 1;
      else r = m;
    end
    return l;
  endfunction

  // ============================================================
  // 10) Binary search - upper bound
  // Pattern: first index i where a[i] > target
  // ============================================================
  function automatic int upper_bound(input int a[], input int target);
    int l, r, m;
    l = 0;
    r = a.size();

    while (l < r) begin
      m = l + ((r - l) >> 1);
      if (a[m] <= target) l = m + 1;
      else r = m;
    end
    return l;
  endfunction

  // ============================================================
  // 11) Binary search on monotonic boolean condition
  // Pattern: first true in monotonic false...false,true...true array
  // ============================================================
  function automatic int first_true(input bit ok[]);
    int l, r, m, ans;
    l = 0;
    r = ok.size() - 1;
    ans = ok.size();

    while (l <= r) begin
      m = l + ((r - l) >> 1);
      if (ok[m]) begin
        ans = m;
        r = m - 1;
      end
      else l = m + 1;
    end
    return ans;
  endfunction

  // ============================================================
  // 12) Binary search - rotated sorted array minimum
  // ============================================================
  function automatic int min_rotated_sorted(input int a[]);
    int l, r, m;
    if (a.size() == 0) return 0;
    l = 0;
    r = a.size() - 1;

    while (l < r) begin
      m = l + ((r - l) >> 1);
      if (a[m] > a[r]) l = m + 1;
      else r = m;
    end
    return a[l];
  endfunction

  // ============================================================
  // 13) Prefix sum
  // Pattern: range sum query in O(1) after O(n) preprocessing
  // pref[0]=0, pref[i+1]=sum a[0..i]
  // ============================================================
  task automatic build_prefix_sum(input int a[], output int pref[]);
    int i;
    pref = new[a.size() + 1];
    pref[0] = 0;
    for (i = 0; i < a.size(); i++) pref[i+1] = pref[i] + a[i];
  endtask

  function automatic int range_sum(input int pref[], input int l, input int r);
    return pref[r+1] - pref[l];
  endfunction

  // ============================================================
  // 14) Prefix sum + hashmap
  // Pattern: number of subarrays with sum == k
  // Works with negative numbers too.
  // ============================================================
  function automatic int count_subarrays_sum_k(input int a[], input int k);
    int cnt[int];
    int sum, ans, i, need;
    cnt[0] = 1;
    sum = 0;
    ans = 0;

    for (i = 0; i < a.size(); i++) begin
      sum += a[i];
      need = sum - k;
      if (cnt.exists(need)) ans += cnt[need];
      cnt[sum]++;
    end
    return ans;
  endfunction

  // ============================================================
  // 15) Difference array
  // Pattern: range increment updates, then reconstruct final array
  // updates[j] = '{l, r, delta}
  // ============================================================
  typedef struct {
    int l;
    int r;
    int delta;
  } range_update_t;

  task automatic apply_range_updates(
    input  int n,
    input  range_update_t updates[],
    output int result[]
  );
    int diff[];
    int i;

    diff = new[n + 1];
    foreach (diff[i]) diff[i] = 0;

    foreach (updates[i]) begin
      diff[updates[i].l] += updates[i].delta;
      if (updates[i].r + 1 < n) diff[updates[i].r + 1] -= updates[i].delta;
    end

    result = new[n];
    result[0] = diff[0];
    for (i = 1; i < n; i++) result[i] = result[i-1] + diff[i];
  endtask

  // ============================================================
  // 16) Hashmap - two-sum unsorted
  // Pattern: value -> index associative array
  // ============================================================
  function automatic bit two_sum_unsorted(
    input  int a[],
    input  int target,
    output int i0,
    output int i1
  );
    int seen[int];
    int i, need;
    i0 = -1;
    i1 = -1;

    for (i = 0; i < a.size(); i++) begin
      need = target - a[i];
      if (seen.exists(need)) begin
        i0 = seen[need];
        i1 = i;
        return 1;
      end
      if (!seen.exists(a[i])) seen[a[i]] = i;
    end
    return 0;
  endfunction

  // ============================================================
  // 17) Stack - valid parentheses
  // Pattern: push opening chars, match closing chars
  // ============================================================
  function automatic bit valid_parentheses(input string s);
    byte st[$];
    byte c, top;
    int i;

    for (i = 0; i < s.len(); i++) begin
      c = s[i];
      if (c == "(" || c == "[" || c == "{") st.push_back(c);
      else begin
        if (st.size() == 0) return 0;
        top = st.pop_back();
        if ((c == ")" && top != "(") ||
            (c == "]" && top != "[") ||
            (c == "}" && top != "{")) return 0;
      end
    end
    return st.size() == 0;
  endfunction

  // ============================================================
  // 18) Monotonic stack - next greater element index
  // Pattern: stack keeps indices with decreasing values
  // ============================================================
  task automatic next_greater_indices(input int a[], output int nge[]);
    int st[$];
    int i, idx;

    nge = new[a.size()];
    foreach (nge[i]) nge[i] = -1;

    for (i = 0; i < a.size(); i++) begin
      while (st.size() > 0 && a[i] > a[st[$]]) begin
        idx = st.pop_back();
        nge[idx] = i;
      end
      st.push_back(i);
    end
  endtask

  // ============================================================
  // 19) Monotonic stack - largest rectangle in histogram
  // ============================================================
  function automatic int largest_rectangle_histogram(input int h[]);
    int st[$];
    int i, height, width, area, best, idx;

    best = 0;
    for (i = 0; i <= h.size(); i++) begin
      height = (i == h.size()) ? 0 : h[i];
      while (st.size() > 0 && height < h[st[$]]) begin
        idx = st.pop_back();
        width = (st.size() == 0) ? i : (i - st[$] - 1);
        area = h[idx] * width;
        if (area > best) best = area;
      end
      st.push_back(i);
    end
    return best;
  endfunction

  // ============================================================
  // 20) Monotonic queue - sliding window maximum
  // Pattern: deque holds candidate indices in decreasing value order
  // ============================================================
  task automatic sliding_window_max(input int a[], input int k, output int out[]);
    int dq[$];
    int i;
    if (k <= 0 || a.size() < k) begin
      out = new[0];
      return;
    end

    out = new[a.size() - k + 1];
    for (i = 0; i < a.size(); i++) begin
      while (dq.size() > 0 && dq[0] <= i - k) void'(dq.pop_front());
      while (dq.size() > 0 && a[dq[$]] <= a[i]) void'(dq.pop_back());
      dq.push_back(i);
      if (i >= k - 1) out[i-k+1] = a[dq[0]];
    end
  endtask

  // ============================================================
  // 21) Intervals - merge overlapping intervals
  // ============================================================
  task automatic merge_intervals(input interval_t intervals[], output interval_t merged[]);
    interval_t tmp[];
    interval_t cur;
    interval_t q[$];
    int i;

    if (intervals.size() == 0) begin
      merged = new[0];
      return;
    end

    tmp = intervals;
    tmp.sort with (item.lo);

    cur = tmp[0];
    for (i = 1; i < tmp.size(); i++) begin
      if (tmp[i].lo <= cur.hi) begin
        if (tmp[i].hi > cur.hi) cur.hi = tmp[i].hi;
      end
      else begin
        q.push_back(cur);
        cur = tmp[i];
      end
    end
    q.push_back(cur);

    merged = new[q.size()];
    foreach (q[i]) merged[i] = q[i];
  endtask

  // ============================================================
  // 22) Intervals - insert interval into sorted non-overlapping list
  // ============================================================
  task automatic insert_interval(
    input  interval_t intervals[],
    input  interval_t new_int,
    output interval_t result[]
  );
    interval_t q[$];
    interval_t cur;
    int i;

    cur = new_int;
    i = 0;
    while (i < intervals.size() && intervals[i].hi < cur.lo) begin
      q.push_back(intervals[i]);
      i++;
    end

    while (i < intervals.size() && intervals[i].lo <= cur.hi) begin
      if (intervals[i].lo < cur.lo) cur.lo = intervals[i].lo;
      if (intervals[i].hi > cur.hi) cur.hi = intervals[i].hi;
      i++;
    end
    q.push_back(cur);

    while (i < intervals.size()) begin
      q.push_back(intervals[i]);
      i++;
    end

    result = new[q.size()];
    foreach (q[i]) result[i] = q[i];
  endtask

  // ============================================================
  // 23) Tree templates: DFS and BFS
  // ============================================================
  class TreeNode;
    int val;
    TreeNode left;
    TreeNode right;

    function new(input int v = 0);
      val = v;
      left = null;
      right = null;
    endfunction
  endclass

  task automatic tree_preorder(input TreeNode root, ref int out[$]);
    if (root == null) return;
    out.push_back(root.val);
    tree_preorder(root.left, out);
    tree_preorder(root.right, out);
  endtask

  task automatic tree_inorder(input TreeNode root, ref int out[$]);
    if (root == null) return;
    tree_inorder(root.left, out);
    out.push_back(root.val);
    tree_inorder(root.right, out);
  endtask

  task automatic tree_postorder(input TreeNode root, ref int out[$]);
    if (root == null) return;
    tree_postorder(root.left, out);
    tree_postorder(root.right, out);
    out.push_back(root.val);
  endtask

  function automatic int tree_max_depth(input TreeNode root);
    int l, r;
    if (root == null) return 0;
    l = tree_max_depth(root.left);
    r = tree_max_depth(root.right);
    return 1 + ((l > r) ? l : r);
  endfunction

  task automatic tree_level_order(
    input  TreeNode root,
    ref    int order[$],
    ref    int level_sizes[$]
  );
    TreeNode q[$];
    TreeNode node;
    int level_count, i;

    if (root == null) return;
    q.push_back(root);

    while (q.size() > 0) begin
      level_count = q.size();
      level_sizes.push_back(level_count);
      for (i = 0; i < level_count; i++) begin
        node = q.pop_front();
        order.push_back(node.val);
        if (node.left != null) q.push_back(node.left);
        if (node.right != null) q.push_back(node.right);
      end
    end
  endtask

  // ============================================================
  // 24) Binary Search Tree - validate using bounds
  // ============================================================
  function automatic bit is_valid_bst_range(input TreeNode root, input longint lo, input longint hi);
    if (root == null) return 1;
    if (root.val <= lo || root.val >= hi) return 0;
    return is_valid_bst_range(root.left, lo, root.val) &&
           is_valid_bst_range(root.right, root.val, hi);
  endfunction

  function automatic bit is_valid_bst(input TreeNode root);
    return is_valid_bst_range(root, longint'(-2147483648) - 1, longint'(2147483647) + 1);
  endfunction

  // ============================================================
  // 25) Graph BFS - adjacency list
  // adj[u] is a queue of neighbors.
  // ============================================================
  task automatic graph_bfs(input int start, ref int_q_t adj[int], ref int order[$]);
    bit visited[int];
    int q[$];
    int u, v, i;

    visited[start] = 1;
    q.push_back(start);

    while (q.size() > 0) begin
      u = q.pop_front();
      order.push_back(u);
      for (i = 0; i < adj[u].size(); i++) begin
        v = adj[u][i];
        if (!visited.exists(v) || !visited[v]) begin
          visited[v] = 1;
          q.push_back(v);
        end
      end
    end
  endtask

  // ============================================================
  // 26) Graph DFS - recursive adjacency list
  // ============================================================
  task automatic graph_dfs_visit(input int u, ref int_q_t adj[int], ref bit visited[int], ref int order[$]);
    int i, v;
    visited[u] = 1;
    order.push_back(u);

    for (i = 0; i < adj[u].size(); i++) begin
      v = adj[u][i];
      if (!visited.exists(v) || !visited[v]) graph_dfs_visit(v, adj, visited, order);
    end
  endtask

  task automatic graph_dfs(input int start, ref int_q_t adj[int], ref int order[$]);
    bit visited[int];
    graph_dfs_visit(start, adj, visited, order);
  endtask

  // ============================================================
  // 27) Grid DFS/BFS - number of islands
  // grid cell: 1 = land, 0 = water
  // ============================================================
  function automatic void flood_fill_island(ref int grid[][], input int r, input int c);
    int rows, cols, nr, nc, k;
    int dr[4];
    int dc[4];

    rows = grid.size();
    cols = grid[0].size();
    dr = '{1, -1, 0, 0};
    dc = '{0, 0, 1, -1};

    if (r < 0 || r >= rows || c < 0 || c >= cols || grid[r][c] == 0) return;
    grid[r][c] = 0;

    for (k = 0; k < 4; k++) begin
      nr = r + dr[k];
      nc = c + dc[k];
      flood_fill_island(grid, nr, nc);
    end
  endfunction

  function automatic int num_islands(ref int grid[][]);
    int rows, cols, r, c, ans;
    if (grid.size() == 0) return 0;
    rows = grid.size();
    cols = grid[0].size();
    ans = 0;

    for (r = 0; r < rows; r++) begin
      for (c = 0; c < cols; c++) begin
        if (grid[r][c] == 1) begin
          ans++;
          flood_fill_island(grid, r, c);
        end
      end
    end
    return ans;
  endfunction

  // ============================================================
  // 28) Backtracking - subsets / power set
  // ============================================================
  task automatic subsets_bt(
    input int nums[],
    input int idx,
    ref   int path[$],
    ref   int ans[$][$]
  );
    if (idx == nums.size()) begin
      ans.push_back(path);
      return;
    end

    // decision 1: skip nums[idx]
    subsets_bt(nums, idx + 1, path, ans);

    // decision 2: take nums[idx]
    path.push_back(nums[idx]);
    subsets_bt(nums, idx + 1, path, ans);
    void'(path.pop_back());
  endtask

  task automatic all_subsets(input int nums[], ref int ans[$][$]);
    int path[$];
    subsets_bt(nums, 0, path, ans);
  endtask

  // ============================================================
  // 29) Backtracking - permutations
  // ============================================================
  task automatic permutations_bt(
    input int nums[],
    ref   bit used[],
    ref   int path[$],
    ref   int ans[$][$]
  );
    int i;
    if (path.size() == nums.size()) begin
      ans.push_back(path);
      return;
    end

    for (i = 0; i < nums.size(); i++) begin
      if (!used[i]) begin
        used[i] = 1;
        path.push_back(nums[i]);
        permutations_bt(nums, used, path, ans);
        void'(path.pop_back());
        used[i] = 0;
      end
    end
  endtask

  task automatic all_permutations(input int nums[], ref int ans[$][$]);
    bit used[];
    int path[$];
    used = new[nums.size()];
    permutations_bt(nums, used, path, ans);
  endtask

  // ============================================================
  // 30) Backtracking - combinations choose k from 1..n
  // ============================================================
  task automatic combinations_bt(
    input int n,
    input int k,
    input int start,
    ref   int path[$],
    ref   int ans[$][$]
  );
    int x;
    if (path.size() == k) begin
      ans.push_back(path);
      return;
    end

    for (x = start; x <= n; x++) begin
      path.push_back(x);
      combinations_bt(n, k, x + 1, path, ans);
      void'(path.pop_back());
    end
  endtask

  task automatic combinations(input int n, input int k, ref int ans[$][$]);
    int path[$];
    combinations_bt(n, k, 1, path, ans);
  endtask

  // ============================================================
  // 31) Backtracking - phone letter combinations
  // digits: '2'..'9'
  // ============================================================
  task automatic phone_bt(
    input string digits,
    input int idx,
    input string path,
    ref   string ans[$]
  );
    string mp[byte];
    string letters;
    int i;

    mp["2"] = "abc"; mp["3"] = "def"; mp["4"] = "ghi"; mp["5"] = "jkl";
    mp["6"] = "mno"; mp["7"] = "pqrs"; mp["8"] = "tuv"; mp["9"] = "wxyz";

    if (idx == digits.len()) begin
      ans.push_back(path);
      return;
    end

    letters = mp[digits[idx]];
    for (i = 0; i < letters.len(); i++) begin
      phone_bt(digits, idx + 1, {path, letters.substr(i, i)}, ans);
    end
  endtask

  task automatic phone_letter_combinations(input string digits, ref string ans[$]);
    if (digits.len() == 0) return;
    phone_bt(digits, 0, "", ans);
  endtask

  // ============================================================
  // 32) Heap / Priority Queue - min heap
  // ============================================================
  class MinHeap;
    heap_item_t h[$];

    function int size();
      return h.size();
    endfunction

    function bit empty();
      return h.size() == 0;
    endfunction

    function bit less(input heap_item_t a, input heap_item_t b);
      if (a.key != b.key) return a.key < b.key;
      return a.node < b.node;
    endfunction

    task push(input int key, input int node = 0);
      heap_item_t item;
      int i, p;
      item.key = key;
      item.node = node;
      h.push_back(item);
      i = h.size() - 1;
      while (i > 0) begin
        p = (i - 1) / 2;
        if (!less(h[i], h[p])) break;
        swap_heap_item(h[i], h[p]);
        i = p;
      end
    endtask

    function heap_item_t top();
      return h[0];
    endfunction

    task pop(output heap_item_t out);
      int i, l, r, best;
      out = h[0];
      h[0] = h[h.size() - 1];
      void'(h.pop_back());

      i = 0;
      while (1) begin
        l = 2*i + 1;
        r = 2*i + 2;
        best = i;
        if (l < h.size() && less(h[l], h[best])) best = l;
        if (r < h.size() && less(h[r], h[best])) best = r;
        if (best == i) break;
        swap_heap_item(h[i], h[best]);
        i = best;
      end
    endtask

    task swap_heap_item(ref heap_item_t a, ref heap_item_t b);
      heap_item_t t;
      t = a;
      a = b;
      b = t;
    endtask
  endclass

  // ============================================================
  // 33) Heap pattern - top K largest using min heap of size K
  // ============================================================
  task automatic top_k_largest(input int a[], input int k, output int out[]);
    MinHeap heap;
    heap_item_t item;
    int i;

    heap = new();
    for (i = 0; i < a.size(); i++) begin
      heap.push(a[i], i);
      if (heap.size() > k) heap.pop(item);
    end

    out = new[heap.size()];
    for (i = heap.size() - 1; i >= 0; i--) begin
      heap.pop(item);
      out[i] = item.key;
    end
  endtask

  // ============================================================
  // 34) Union Find / Disjoint Set Union
  // Pattern: connected components, cycle detection, Kruskal
  // ============================================================
  class DSU;
    int parent[];
    int rank[];

    function new(input int n);
      int i;
      parent = new[n];
      rank = new[n];
      for (i = 0; i < n; i++) begin
        parent[i] = i;
        rank[i] = 0;
      end
    endfunction

    function int find(input int x);
      if (parent[x] != x) parent[x] = find(parent[x]);
      return parent[x];
    endfunction

    function bit unite(input int a, input int b);
      int ra, rb;
      ra = find(a);
      rb = find(b);
      if (ra == rb) return 0;

      if (rank[ra] < rank[rb]) parent[ra] = rb;
      else if (rank[ra] > rank[rb]) parent[rb] = ra;
      else begin
        parent[rb] = ra;
        rank[ra]++;
      end
      return 1;
    endfunction
  endclass

  // ============================================================
  // 35) Topological sort - Kahn BFS
  // Pattern: DAG order / course schedule
  // ============================================================
  function automatic bit topo_sort_kahn(
    input int n,
    ref   int_q_t adj[int],
    ref   int topo[$]
  );
    int indeg[];
    int q[$];
    int u, v, i;

    indeg = new[n];
    foreach (indeg[i]) indeg[i] = 0;

    for (u = 0; u < n; u++) begin
      for (i = 0; i < adj[u].size(); i++) begin
        v = adj[u][i];
        indeg[v]++;
      end
    end

    for (u = 0; u < n; u++) if (indeg[u] == 0) q.push_back(u);

    while (q.size() > 0) begin
      u = q.pop_front();
      topo.push_back(u);
      for (i = 0; i < adj[u].size(); i++) begin
        v = adj[u][i];
        indeg[v]--;
        if (indeg[v] == 0) q.push_back(v);
      end
    end
    return topo.size() == n;
  endfunction

  // ============================================================
  // 36) Shortest path - Dijkstra with min heap
  // Weighted directed graph with non-negative weights.
  // ============================================================
  task automatic dijkstra(
    input int n,
    input int src,
    ref   edge_q_t adj[int],
    output int dist[]
  );
    MinHeap pq;
    heap_item_t item;
    int u, v, w, i;

    dist = new[n];
    foreach (dist[i]) dist[i] = 32'h3fffffff;
    dist[src] = 0;

    pq = new();
    pq.push(0, src);

    while (!pq.empty()) begin
      pq.pop(item);
      u = item.node;
      if (item.key != dist[u]) continue;

      for (i = 0; i < adj[u].size(); i++) begin
        v = adj[u][i].to;
        w = adj[u][i].w;
        if (dist[u] + w < dist[v]) begin
          dist[v] = dist[u] + w;
          pq.push(dist[v], v);
        end
      end
    end
  endtask

  // ============================================================
  // 37) Trie / Prefix tree
  // Pattern: prefix search, autocomplete, word dictionary
  // ============================================================
  class TrieNode;
    bit is_word;
    TrieNode child[byte];

    function new();
      is_word = 0;
    endfunction
  endclass

  class Trie;
    TrieNode root;

    function new();
      root = new();
    endfunction

    task insert(input string word);
      TrieNode cur;
      byte c;
      int i;
      cur = root;
      for (i = 0; i < word.len(); i++) begin
        c = word[i];
        if (!cur.child.exists(c)) cur.child[c] = new();
        cur = cur.child[c];
      end
      cur.is_word = 1;
    endtask

    function bit search(input string word);
      TrieNode cur;
      byte c;
      int i;
      cur = root;
      for (i = 0; i < word.len(); i++) begin
        c = word[i];
        if (!cur.child.exists(c)) return 0;
        cur = cur.child[c];
      end
      return cur.is_word;
    endfunction

    function bit starts_with(input string prefix);
      TrieNode cur;
      byte c;
      int i;
      cur = root;
      for (i = 0; i < prefix.len(); i++) begin
        c = prefix[i];
        if (!cur.child.exists(c)) return 0;
        cur = cur.child[c];
      end
      return 1;
    endfunction
  endclass

  // ============================================================
  // 38) Dynamic Programming - top-down memoization
  // Pattern: recursion + associative-array memo
  // ============================================================
  function automatic longint fib_top_down(input int n, ref longint memo[int]);
    if (n <= 1) return n;
    if (memo.exists(n)) return memo[n];
    memo[n] = fib_top_down(n - 1, memo) + fib_top_down(n - 2, memo);
    return memo[n];
  endfunction

  // ============================================================
  // 39) Dynamic Programming - bottom-up tabulation
  // Pattern: build dp[0..n]
  // ============================================================
  function automatic longint fib_bottom_up(input int n);
    longint dp[];
    int i;
    if (n <= 1) return n;
    dp = new[n + 1];
    dp[0] = 0;
    dp[1] = 1;
    for (i = 2; i <= n; i++) dp[i] = dp[i-1] + dp[i-2];
    return dp[n];
  endfunction

  // ============================================================
  // 40) DP - 1D rolling array
  // Pattern: climbing stairs / Fibonacci-like recurrence
  // ============================================================
  function automatic longint climb_stairs(input int n);
    longint a, b, c;
    int i;
    if (n <= 2) return n;
    a = 1;
    b = 2;
    for (i = 3; i <= n; i++) begin
      c = a + b;
      a = b;
      b = c;
    end
    return b;
  endfunction

  // ============================================================
  // 41) DP - coin change minimum coins
  // Pattern: unbounded knapsack min
  // ============================================================
  function automatic int coin_change_min(input int coins[], input int amount);
    int dp[];
    int i, coin;
    int INF;
    INF = 32'h3fffffff;

    dp = new[amount + 1];
    foreach (dp[i]) dp[i] = INF;
    dp[0] = 0;

    foreach (coins[i]) begin
      coin = coins[i];
      for (int x = coin; x <= amount; x++) begin
        if (dp[x - coin] != INF && dp[x - coin] + 1 < dp[x]) dp[x] = dp[x - coin] + 1;
      end
    end
    return (dp[amount] == INF) ? -1 : dp[amount];
  endfunction

  // ============================================================
  // 42) DP - 0/1 knapsack
  // Pattern: descending capacity loop to avoid reusing same item
  // ============================================================
  function automatic int knapsack_01(input int wt[], input int val[], input int cap);
    int dp[];
    int i, c;
    dp = new[cap + 1];
    foreach (dp[c]) dp[c] = 0;

    for (i = 0; i < wt.size(); i++) begin
      for (c = cap; c >= wt[i]; c--) begin
        if (dp[c - wt[i]] + val[i] > dp[c]) dp[c] = dp[c - wt[i]] + val[i];
      end
    end
    return dp[cap];
  endfunction

  // ============================================================
  // 43) DP - Longest Common Subsequence
  // Pattern: 2D table on two strings
  // ============================================================
  function automatic int lcs_length(input string a, input string b);
    int dp[][];
    int i, j;

    dp = new[a.len() + 1];
    foreach (dp[i]) dp[i] = new[b.len() + 1];

    for (i = 1; i <= a.len(); i++) begin
      for (j = 1; j <= b.len(); j++) begin
        if (a[i-1] == b[j-1]) dp[i][j] = dp[i-1][j-1] + 1;
        else dp[i][j] = (dp[i-1][j] > dp[i][j-1]) ? dp[i-1][j] : dp[i][j-1];
      end
    end
    return dp[a.len()][b.len()];
  endfunction

  // ============================================================
  // 44) DP + binary search - Longest Increasing Subsequence O(n log n)
  // ============================================================
  function automatic int lis_length(input int a[]);
    int tails[$];
    int i, pos;
    for (i = 0; i < a.size(); i++) begin
      pos = lower_bound_queue(tails, a[i]);
      if (pos == tails.size()) tails.push_back(a[i]);
      else tails[pos] = a[i];
    end
    return tails.size();
  endfunction

  function automatic int lower_bound_queue(input int q[$], input int target);
    int l, r, m;
    l = 0;
    r = q.size();
    while (l < r) begin
      m = l + ((r - l) >> 1);
      if (q[m] < target) l = m + 1;
      else r = m;
    end
    return l;
  endfunction

  // ============================================================
  // 45) DP - grid unique paths with obstacles
  // grid cell: 0 = free, 1 = obstacle
  // ============================================================
  function automatic longint unique_paths_obstacles(input int grid[][]);
    longint dp[];
    int rows, cols, r, c;

    if (grid.size() == 0) return 0;
    rows = grid.size();
    cols = grid[0].size();
    dp = new[cols];
    dp[0] = (grid[0][0] == 0);

    for (r = 0; r < rows; r++) begin
      for (c = 0; c < cols; c++) begin
        if (grid[r][c] == 1) dp[c] = 0;
        else if (c > 0) dp[c] += dp[c-1];
      end
    end
    return dp[cols-1];
  endfunction

  // ============================================================
  // 46) Greedy - activity selection / non-overlapping intervals
  // Pattern: sort by ending time, choose earliest finishing compatible interval
  // ============================================================
  function automatic int max_nonoverlap_intervals(input interval_t intervals[]);
    interval_t tmp[];
    int count, last_end, i;

    if (intervals.size() == 0) return 0;
    tmp = intervals;
    tmp.sort with (item.hi);

    count = 0;
    last_end = -32'sh7fffffff;
    for (i = 0; i < tmp.size(); i++) begin
      if (tmp[i].lo >= last_end) begin
        count++;
        last_end = tmp[i].hi;
      end
    end
    return count;
  endfunction

  // ============================================================
  // 47) Greedy - jump game
  // Pattern: maintain farthest reachable index
  // ============================================================
  function automatic bit can_jump(input int nums[]);
    int farthest, i;
    farthest = 0;
    for (i = 0; i < nums.size(); i++) begin
      if (i > farthest) return 0;
      if (i + nums[i] > farthest) farthest = i + nums[i];
    end
    return 1;
  endfunction

  // ============================================================
  // 48) Bit manipulation - count set bits
  // Pattern: x &= x-1 clears the lowest set bit
  // ============================================================
  function automatic int popcount32(input int unsigned x);
    int cnt;
    cnt = 0;
    while (x != 0) begin
      x = x & (x - 1);
      cnt++;
    end
    return cnt;
  endfunction

  // ============================================================
  // 49) Bit manipulation - single number using XOR
  // Pattern: pairs cancel out
  // ============================================================
  function automatic int single_number_xor(input int a[]);
    int x, i;
    x = 0;
    for (i = 0; i < a.size(); i++) x ^= a[i];
    return x;
  endfunction

  // ============================================================
  // 50) Bitmask enumeration - all subsets of n elements
  // Pattern: iterate masks from 0 to 2^n - 1
  // ============================================================
  task automatic subsets_bitmask(input int nums[], ref int ans[$][$]);
    int n, mask, i;
    int path[$];
    n = nums.size();

    for (mask = 0; mask < (1 << n); mask++) begin
      path.delete();
      for (i = 0; i < n; i++) begin
        if ((mask >> i) & 1) path.push_back(nums[i]);
      end
      ans.push_back(path);
    end
  endtask

  // ============================================================
  // 51) Sorting comparator templates
  // Pattern: use SystemVerilog array methods
  // ============================================================
  task automatic sort_ascending(ref int a[]);
    a.sort();
  endtask

  task automatic sort_descending(ref int a[]);
    a.rsort();
  endtask

  task automatic sort_intervals_by_start(ref interval_t intervals[]);
    intervals.sort with (item.lo);
  endtask

  // ============================================================
  // 52) Matrix / grid traversal template
  // Pattern: four-direction traversal with boundary checks
  // ============================================================
  task automatic neighbors4(
    input int r,
    input int c,
    input int rows,
    input int cols,
    ref   int nr_q[$],
    ref   int nc_q[$]
  );
    int dr[4];
    int dc[4];
    int k, nr, nc;
    dr = '{1, -1, 0, 0};
    dc = '{0, 0, 1, -1};

    for (k = 0; k < 4; k++) begin
      nr = r + dr[k];
      nc = c + dc[k];
      if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) begin
        nr_q.push_back(nr);
        nc_q.push_back(nc);
      end
    end
  endtask


  // ============================================================
  // 53) Heap pattern - top K smallest using max-heap behavior
  // Implemented with MinHeap by storing negative keys.
  // ============================================================
  task automatic top_k_smallest(input int a[], input int k, output int out[]);
    MinHeap heap;
    heap_item_t item;
    int i;

    heap = new();
    for (i = 0; i < a.size(); i++) begin
      heap.push(-a[i], i);          // smallest heap key = largest actual value
      if (heap.size() > k) heap.pop(item);
    end

    out = new[heap.size()];
    for (i = heap.size() - 1; i >= 0; i--) begin
      heap.pop(item);
      out[i] = -item.key;
    end
  endtask

  // ============================================================
  // 54) Kadane's algorithm
  // Pattern: maximum subarray sum in O(n)
  // ============================================================
  function automatic int max_subarray_sum(input int a[]);
    int best, cur, i;
    if (a.size() == 0) return 0;

    best = a[0];
    cur = a[0];
    for (i = 1; i < a.size(); i++) begin
      cur = ((cur + a[i]) > a[i]) ? (cur + a[i]) : a[i];
      if (cur > best) best = cur;
    end
    return best;
  endfunction

  // ============================================================
  // 55) Cyclic sort
  // Pattern: numbers are in a known range, usually 1..n.
  // Places value x at index x-1 when possible.
  // ============================================================
  task automatic cyclic_sort_1_to_n(ref int a[]);
    int i, correct_idx;
    i = 0;
    while (i < a.size()) begin
      correct_idx = a[i] - 1;
      if (a[i] >= 1 && a[i] <= a.size() && a[i] != a[correct_idx]) begin
        swap_int(a[i], a[correct_idx]);
      end
      else i++;
    end
  endtask

  // Example use after cyclic_sort_1_to_n: first missing positive.
  function automatic int first_missing_positive(ref int a[]);
    int i;
    cyclic_sort_1_to_n(a);
    for (i = 0; i < a.size(); i++) begin
      if (a[i] != i + 1) return i + 1;
    end
    return a.size() + 1;
  endfunction

  // ============================================================
  // 56) Fast exponentiation / binary exponentiation
  // Pattern: exponent halves each step, O(log exponent)
  // ============================================================
  function automatic longint fast_pow(input longint base, input int exp);
    longint ans, b;
    int e;
    ans = 1;
    b = base;
    e = exp;

    while (e > 0) begin
      if (e & 1) ans *= b;
      b *= b;
      e >>= 1;
    end
    return ans;
  endfunction

  // ============================================================
  // 57) Boyer-Moore majority vote
  // Pattern: candidate cancellation for majority element > n/2
  // ============================================================
  function automatic int majority_element(input int a[]);
    int cand, cnt, i;
    cand = 0;
    cnt = 0;

    for (i = 0; i < a.size(); i++) begin
      if (cnt == 0) begin
        cand = a[i];
        cnt = 1;
      end
      else if (a[i] == cand) cnt++;
      else cnt--;
    end
    return cand;
  endfunction

endpackage : sv_interview_patterns_pkg
