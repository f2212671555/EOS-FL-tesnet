


def combine_params(para_A,para_B,para_C):
  fc1_wA=para_A[0][1].data
  fc1_wB=para_B[0][1].data
  fc1_wC=para_C[0][1].data

  fc2_wA=para_A[2][1].data
  fc2_wB=para_B[2][1].data
  fc2_wC=para_C[2][1].data

  com_para_fc1=(fc1_wA+fc1_wB+fc1_wC)/3
  com_para_fc2=(fc2_wA+fc2_wB+fc2_wC)/3
  return com_para_fc1,com_para_fc2