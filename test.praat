syll_tier = 3
i_syll = 2
seg_tier = 2
vot_tier = 1
i_cons = 2
i_vowel = 3
i_vot = 3
i_cl = 2

@getDurLab: syll_tier, i_syll
@getDurLab: seg_tier, i_cons
@getDurLab: seg_tier, i_vowel
@getDurLab: vot_tier, i_vot
@getDurLab: vot_tier, i_cl

procedure getDurLab: .tier_num, .i_intv
  .intv_start = Get starting point: .tier_num, .i_intv
  .intv_end = Get end point: .tier_num, .i_intv
  .intv_dur = .intv_end - .intv_start
  .intv_label$ = Get label of interval: .tier_num, .i_intv
endproc
