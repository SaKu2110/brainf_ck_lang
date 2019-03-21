class Brainf_ck

  class ProgramError < StandardError; end

  def initialize(src)
    # ソースコードを文字単位で分解
    @tokens = src.chars.to_a
    # ジャンプの位置を特定する
    @jumps = identify_jump_point(@tokens)
  end

  def decode
    pointer = []
    process_num = 0
    pointer_num = 0

    # 命令文の処理
    while process_num < @tokens.size
      case @tokens[process_num]
      when "+"
        pointer[pointer_num] ||= 0
        pointer[pointer_num] += 1
      when "-"
        pointer[pointer_num] ||= 0
        pointer[pointer_num] -= 1
      when ">"
        pointer_num += 1
      when "<"
        pointer_num -= 1
        # ポインターの番号が負の時のエラー処理
        raise ProgramError, "ポインターが左端を指しているためこれ以上移動が出来ません" if pointer_num < 0
      when "["
        if pointer[pointer_num] == 0
          process_num = @jumps[process_num]
        end
      when "]"
        if pointer[pointer_num]!= 0
          process_num = @jumps[process_num]
        end
      when "."
        period = (pointer[pointer_num] || 0)
        print period.chr
      when ","
        pointer[pointer_num] = $stdin.getc.ord
      end

      # 処理が完了したら１増やす
      process_num += 1
    end
  end

  private

  def identify_jump_point(tokens)
    # ジャンプの始点と終点を記録する
    jump_points = {}
    # [ の位置を記録する
    start_points = []

    tokens.each_with_index do |str, point|
      if str == "["
        start_points.push(point)
      elsif str == "]"
        # ] が多い時のエラー処理
        raise ProgramError, "「]」が多すぎます" if start_points.empty?

        from = start_points.pop
        to = point

        jump_points[from] = to
        jump_points[to] = from
      end
    end
    # [ が多い時のエラー処理
    raise ProgramError, "「[」が多すぎます" unless start_points.empty?

    jump_points
  end

end

Brainf_ck.new(ARGF.read).decode
