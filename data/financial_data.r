financial_data <- function()
{
  # CDAX
  df_data <- data.frame(name = "CDAX stock market index",
                        mnemonic = "cdax",
                        category = "financial",
                        group = "financial",
                        trafo = "log, diff",
                        frequency = "M",
                        code = "BBK01.WU001A"
                        )
# NEER 19
  df_data <- rbind(df_data, data.frame(name = "Nominal effective exchange rate (narrow) ",
                                        mnemonic = "neer19",
                                        category = "financial",
                                        group = "financial",
                                        trafo = "log, diff",
                                        frequency = "M",
                                        code = "BBEE1.M.I8.AAA.XZE012.A.AABAN.M00"
                                        )
                )
# NEER 38
  df_data <- rbind(df_data, data.frame(name = "Nominal effective exchange rate (broad) ",
                                        mnemonic = "neer38",
                                        category = "financial",
                                        group = "financial",
                                        trafo = "log, diff",
                                        frequency = "M",
                                        code = "BBEE1.M.I8.AAA.XZE021.A.AABAN.M00"
                                        )
                )

# government bond yields (1y)
  df_data <- rbind(df_data, data.frame(name = "Government bond yields (1y)",
                                        mnemonic = "i1y",
                                        category = "financial",
                                        group = "financial",
                                        trafo = "diff",
                                        frequency = "M",
                                        code = "BBK01.WZ9808"
                                        )
                )

# government bond yields (5y)
  df_data <- rbind(df_data, data.frame(name = "Government bond yields (5y)",
                                        mnemonic = "i5y",
                                        category = "financial",
                                        group = "financial",
                                        trafo = "diff",
                                        frequency = "M",
                                        code = "BBK01.WZ9816"
                                        )
                )

# government bond yields (10y)
  df_data <- rbind(df_data, data.frame(name = "Government bond yields (10y)",
                                        mnemonic = "i10y",
                                        category = "financial",
                                        group = "financial",
                                        trafo = "diff",
                                        frequency = "M",
                                        code = "BBK01.WZ9826"
                                        )
                )

# commodity prices energy
  df_data <- rbind(df_data, data.frame(name = "commodity prices (energy)",
                                        mnemonic = "comm_en",
                                        category = "financial",
                                        group = "financial",
                                        trafo = "log, diff",
                                        frequency = "M",
                                        code = "BBDG1.M.HWWI.N.EURO.ENERGY00.I15.EUR.A"
                                        )
                )  

# commodity prices ex energy
  df_data <- rbind(df_data, data.frame(name = "commodity prices (ex energy)",
                                        mnemonic = "comm_exen",
                                        category = "financial",
                                        group = "financial",
                                        trafo = "log, diff",
                                        frequency = "M",
                                        code = "BBDG1.M.HWWI.N.EURO.TOTNXNGY.I15.EUR.A"
                                        )
                )  
  
  return(df_data)
}

