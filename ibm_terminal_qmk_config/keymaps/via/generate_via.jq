def key_label($k): ($k.matrix[0]|tostring) + "," + ($k.matrix[1]|tostring);
def key_obj($k): ({} + (if (($k.w // 1) != 1) then {w:$k.w} else {} end) + (if (($k.h // 1) != 1) then {h:$k.h} else {} end));

def row_to_kle($row; $y_delta):
  ($row | sort_by(.x)) as $keys
  | ($keys[0]) as $first
  | ([(({x:$first.x} + (if ($y_delta != 0) then {y:$y_delta} else {} end) + key_obj($first))), key_label($first)]
    + (reduce range(1; ($keys|length)) as $i
        ([];
          ($keys[$i-1]) as $prev
          | ($keys[$i]) as $cur
          | ($cur.x - ($prev.x + ($prev.w // 1))) as $dx
          | . + (if ((($dx|abs) > 0.0001) or (($cur.w // 1) != 1) or (($cur.h // 1) != 1)
                 then [({} + (if (($dx|abs) > 0.0001) then {x:$dx} else {} end) + key_obj($cur)), key_label($cur)]
                 else [key_label($cur)]
                 end)
        )
      )
    );

(.layouts.LAYOUT.layout | sort_by(.y, .x)) as $all
| ($all | group_by(.y)) as $rows
| {
    name: .keyboard_name,
    vendorId: .usb.vid,
    productId: .usb.pid,
    matrix: {rows: 17, cols: 8},
    layouts: {
      keymap: (
        reduce range(0; ($rows|length)) as $ri
          ([];
            . + [
              row_to_kle(
                $rows[$ri];
                if $ri == 0 then ($rows[$ri][0].y) else ($rows[$ri][0].y - $rows[$ri-1][0].y - 1) end
              )
            ]
          )
      )
    }
  }
