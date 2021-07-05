realtime_data <- function()
{
  #######################################################################################
  # gross domestic product and expenditure side 
  #######################################################################################
 
  df_data <- data.frame(name = "gross domestic product",
                        mnemonic = "gdp",
                        category = "national accounts (expenditure)",
                        group = "activity",
                        trafo = "log, diff",
                        frequency = "Q",
                        code = "BBKRT.Q.DE.Y.A.AG1.CA010.A.I",
                        code_deflate = NA
                        )
  
  df_data <- rbind(df_data, data.frame(name = "implicit deflator gross domestic product",
                            mnemonic = "p_gdp",
                            category = "national accounts (expenditure)",
                            group = "prices",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.AG1.CA010.A.I",
                            code_deflate = "BBKRT.Q.DE.Y.A.AG1.CA010.V.A"
                            )
                  )

  df_data <- rbind(df_data, data.frame(name = "private consumption",
                            mnemonic = "c_priv",
                            category = "national accounts (expenditure)",
                            group = "activity",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CA1.BA100.A.I",
                            code_deflate = NA
                            )
                  )
  
  df_data <- rbind(df_data, data.frame(name = "implicit deflator private consumption",
                            mnemonic = "p_c_priv",
                            category = "national accounts (expenditure)",
                            group = "prices",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CA1.BA100.A.I",
                            code_deflate = "BBKRT.Q.DE.Y.A.CA1.BA100.V.A"
                            )
                  )
  df_data <- rbind(df_data, data.frame(name = "government consumption",
                            mnemonic = "c_gov",
                            category = "national accounts (expenditure)",
                            group = "activity",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CA1.BA100.A.I",
                            code_deflate = NA
                            )
                  )
  
  df_data <- rbind(df_data, data.frame(name = "implicit deflator government consumption",
                            mnemonic = "p_c_gov",
                            category = "national accounts (expenditure)",
                            group = "prices",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CA1.BA200.A.I",
                            code_deflate = "BBKRT.Q.DE.Y.A.CA1.BA200.V.A"
                            )
                  )

  df_data <- rbind(df_data, data.frame(name = "equipment investment",
                            mnemonic = "gfcf_equip",
                            category = "national accounts (expenditure)",
                            group = "activity",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CE1.CA010.A.I",
                            code_deflate = NA
                            )
                  )
  
  df_data <- rbind(df_data, data.frame(name = "implicit deflator equipment investment",
                            mnemonic = "p_gfcf_equip",
                            category = "national accounts (expenditure)",
                            group = "prices",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CE1.CA010.A.I",
                            code_deflate = "BBKRT.Q.DE.Y.A.CE1.CA010.V.A"
                            )
                  )

  df_data <- rbind(df_data, data.frame(name = "construction investment",
                            mnemonic = "gfcf_constr",
                            category = "national accounts (expenditure)",
                            group = "activity",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CF1.CA010.A.I",
                            code_deflate = NA
                            )
                  )
  
  df_data <- rbind(df_data, data.frame(name = "implicit deflator construction investment",
                            mnemonic = "p_gfcf_constr",
                            category = "national accounts (expenditure)",
                            group = "prices",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CF1.CA010.A.I",
                            code_deflate = "BBKRT.Q.DE.Y.A.CF1.CA010.V.A"
                            )
                  )
  df_data <- rbind(df_data, data.frame(name = "other investment",
                            mnemonic = "gfcf_other",
                            category = "national accounts (expenditure)",
                            group = "activity",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CI1.CA010.A.I",
                            code_deflate = NA
                            )
                  )
  
  df_data <- rbind(df_data, data.frame(name = "implicit deflator other investment",
                            mnemonic = "p_gfcf_other",
                            category = "national accounts (expenditure)",
                            group = "prices",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CI1.CA010.A.I",
                            code_deflate = "BBKRT.Q.DE.Y.A.CI1.CA010.V.A"
                            )
                  ) 

  df_data <- rbind(df_data, data.frame(name = "exports",
                            mnemonic = "x",
                            category = "national accounts (expenditure)",
                            group = "activity",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CX1.CA010.A.I",
                            code_deflate = NA
                            )
                  )
  
  df_data <- rbind(df_data, data.frame(name = "implicit deflator exports",
                            mnemonic = "p_x",
                            category = "national accounts (expenditure)",
                            group = "prices",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CX1.CA010.A.I",
                            code_deflate = "BBKRT.Q.DE.Y.A.CX1.CA010.V.A"
                            )
                  ) 
  df_data <- rbind(df_data, data.frame(name = "imports",
                            mnemonic = "m",
                            category = "national accounts (expenditure)",
                            group = "activity",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CM1.CA010.A.I",
                            code_deflate = NA
                            )
                  )
  
  df_data <- rbind(df_data, data.frame(name = "implicit deflator imports",
                            mnemonic = "p_m",
                            category = "national accounts (expenditure)",
                            group = "prices",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CM1.CA010.A.I",
                            code_deflate = "BBKRT.Q.DE.Y.A.CM1.CA010.V.A"
                            )
                  ) 

  
  df_data <- rbind(df_data, data.frame(name = "inventories",
                            mnemonic = "inv",
                            category = "national accounts (expenditure)",
                            group = "activity",
                            trafo = "none",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.CJ1.CA010.A.G",
                            code_deflate = NA
                            )
                  )
  
  #######################################################################################
  # gross value added 
  #######################################################################################

  df_data <- rbind(df_data, data.frame(name = "gva industry",
                            mnemonic = "gva_ind",
                            category = "national accounts (production)",
                            group = "activity",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.AU1.AA020.A.I",
                            code_deflate = NA
                            )
                  )
  df_data <- rbind(df_data, data.frame(name = "gva industry deflator",
                            mnemonic = "p_gva_ind",
                            category = "national accounts (production)",
                            group = "activity",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.AU1.AA020.A.I",
                            code_deflate = "BBKRT.Q.DE.Y.A.AU1.AA020.V.A"
                            )
                  )

  df_data <- rbind(df_data, data.frame(name = "gva construction",
                            mnemonic = "gva_constr",
                            category = "national accounts (production)",
                            group = "activity",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.AU1.AA030.A.I",
                            code_deflate = NA
                            )
                  )
  df_data <- rbind(df_data, data.frame(name = "gva construction",
                            mnemonic = "p_gva_constr",
                            category = "national accounts (production)",
                            group = "activity",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.AU1.AA030.A.I",
                            code_deflate = "BBKRT.Q.DE.Y.A.AU1.AA030.V.A"
                            )
                  )

  df_data <- rbind(df_data, data.frame(name = "gva trade, transport, hospitality",
                            mnemonic = "gva_tth",
                            category = "national accounts (production)",
                            group = "activity",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.AU1.AA040.A.I",
                            code_deflate = NA
                            )
                  )
  df_data <- rbind(df_data, data.frame(name = "gva trade, transport, hospitality deflator",
                            mnemonic = "p_gva_tth",
                            category = "national accounts (production)",
                            group = "activity",
                            trafo = "log, diff",
                            frequency = "Q",
                            code = "BBKRT.Q.DE.Y.A.AU1.AA040.A.I",
                            code_deflate = "BBKRT.Q.DE.Y.A.AU1.AA040.V.A"
                            )
                  )
  # the following series are commented out because the vintages are only available until 2011
  #
  # df_data <- rbind(df_data, data.frame(name = "gva finance, real estate, professional services",
  #                           mnemonic = "gva_freprof",
  #                           category = "national accounts (production)",
  #                           group = "activity",
  #                           trafo = "log, diff",
  #                           frequency = "Q",
  #                           code = "BBKRT.Q.DE.Y.A.AU1.AA050.A.I",
  #                           code_deflate = NA
  #                           )
  #                 )

  # df_data <- rbind(df_data, data.frame(name = "gva finance, real estate, professional services",
  #                           mnemonic = "p_gva_freprof",
  #                           category = "national accounts (production)",
  #                           group = "activity",
  #                           trafo = "log, diff",
  #                           frequency = "Q",
  #                           code = "BBKRT.Q.DE.Y.A.AU1.AA050.A.I",
  #                           code_deflate = "BBKRT.Q.DE.Y.A.AU1.AA050.V.A"
  #                           )
  #                 )
  # the following series are commented out because the vintages are only available from 2011 onwards
  #
  # df_data <- rbind(df_data, data.frame(name = "gva finance",
  #                           mnemonic = "gva_fin",
  #                           category = "national accounts (production)",
  #                           group = "activity",
  #                           trafo = "log, diff",
  #                           frequency = "Q",
  #                           code = "BBKRT.Q.DE.Y.A.AU1.AA052.A.I",
  #                           code_deflate = NA
  #                           )
  #                 )
  # df_data <- rbind(df_data, data.frame(name = "gva finance deflator",
  #                           mnemonic = "p_gva_fin",
  #                           category = "national accounts (production)",
  #                           group = "activity",
  #                           trafo = "log, diff",
  #                           frequency = "Q",
  #                           code = "BBKRT.Q.DE.Y.A.AU1.AA052.A.I",
  #                           code_deflate = "BBKRT.Q.DE.Y.A.AU1.AA052.V.A"
  #                           )
  #                 )

  # df_data <- rbind(df_data, data.frame(name = "gva information, communication",
  #                           mnemonic = "gva_ic",
  #                           category = "national accounts (production)",
  #                           group = "activity",
  #                           trafo = "log, diff",
  #                           frequency = "Q",
  #                           code = "BBKRT.Q.DE.Y.A.AU1.AA051.A.I",
  #                           code_deflate = NA
  #                           )
  #                 )

  # df_data <- rbind(df_data, data.frame(name = "gva information communication deflator",
  #                           mnemonic = "p_gva_ic",
  #                           category = "national accounts (production)",
  #                           group = "activity",
  #                           trafo = "log, diff",
  #                           frequency = "Q",
  #                           code = "BBKRT.Q.DE.Y.A.AU1.AA051.A.I",
  #                           code_deflate = "BBKRT.Q.DE.Y.A.AU1.AA051.V.A"
  #                           )
  #                 )
  
  # df_data <- rbind(df_data, data.frame(name = "gva real estate",
  #                           mnemonic = "gva_re",
  #                           category = "national accounts (production)",
  #                           group = "activity",
  #                           trafo = "log, diff",
  #                           frequency = "Q",
  #                           code = "BBKRT.Q.DE.Y.A.AU1.AA061.A.I",
  #                           code_deflate = NA
  #                           )
  #                 )

  # df_data <- rbind(df_data, data.frame(name = "gva real estate deflator",
  #                           mnemonic = "p_gva_re",
  #                           category = "national accounts (production)",
  #                           group = "activity",
  #                           trafo = "log, diff",
  #                           frequency = "Q",
  #                           code = "BBKRT.Q.DE.Y.A.AU1.AA061.A.I",
  #                           code_deflate = "BBKRT.Q.DE.Y.A.AU1.AA061.V.A"
  #                           )
  #                 )

  # df_data <- rbind(df_data, data.frame(name = "gva professional services",
  #                           mnemonic = "gva_profserv",
  #                           category = "national accounts (production)",
  #                           group = "activity",
  #                           trafo = "log, diff",
  #                           frequency = "Q",
  #                           code = "BBKRT.Q.DE.Y.A.AU1.AA062.A.I",
  #                           code_deflate = NA
  #                           )
  #                 )

  # df_data <- rbind(df_data, data.frame(name = "gva professional services deflator",
  #                           mnemonic = "p_gva_profserv",
  #                           category = "national accounts (production)",
  #                           group = "activity",
  #                           trafo = "log, diff",
  #                           frequency = "Q",
  #                           code = "BBKRT.Q.DE.Y.A.AU1.AA062.A.I",
  #                           code_deflate = "BBKRT.Q.DE.Y.A.AU1.AA062.V.A"
  #                           )
  #                 )

  # df_data <- rbind(df_data, data.frame(name = "gva public services",
  #                           mnemonic = "gva_pub",
  #                           category = "national accounts (production)",
  #                           group = "activity",
  #                           trafo = "log, diff",
  #                           frequency = "Q",
  #                           code = "BBKRT.Q.DE.Y.A.AU1.AA063.A.I",
  #                           code_deflate = NA
  #                           )
  #                 )

  # df_data <- rbind(df_data, data.frame(name = "gva public services deflator",
  #                           mnemonic = "p_gva_pub",
  #                           category = "national accounts (production)",
  #                           group = "activity",
  #                           trafo = "log, diff",
  #                           frequency = "Q",
  #                           code = "BBKRT.Q.DE.Y.A.AU1.AA063.A.I",
  #                           code_deflate = "BBKRT.Q.DE.Y.A.AU1.AA063.V.A"
  #                           )
  #                 )

  #######################################################################################
  # prices
  #######################################################################################
                  
  df_data <- rbind(df_data, 
                   data.frame(name = "CPI inflation",
                              mnemonic = "cpi",
                              category = "prices",
                              group = "prices",
                              trafo = "log, diff",
                              frequency = "M",
                              code = "BBKRT.M.DE.Y.P.PC1.PC100.R.I",
                              code_deflate = NA 
                              )
                   )

  df_data <- rbind(df_data, 
                   data.frame(name = "core CPI inflation",
                              mnemonic = "cpi_core",
                              category = "prices",
                              group = "prices",
                              trafo = "log, diff",
                              frequency = "M",
                              code = "BBKRT.M.DE.S.P.PC1.PC110.R.I" , 
                              code_deflate = NA 
                              )
                   )

  df_data <- rbind(df_data, 
                   data.frame(name = "PPI inflation",
                              mnemonic = "ppi",
                              category = "prices",
                              group = "prices",
                              trafo = "log, diff",
                              frequency = "M",
                              code = "BBKRT.M.DE.S.P.PP1.PP100.R.I",
                              code_deflate = NA 
                              )
                   )
  
  df_data <- rbind(df_data, 
                   data.frame(name = "core PPI inflation",
                              mnemonic = "ppi_core",
                              category = "prices",
                              group = "prices",
                              trafo = "log, diff",
                              frequency = "M",
                              code = "BBKRT.M.DE.S.P.PP1.PP200.R.I",
                              code_deflate = NA 
                              )
                   )  
  df_data <- rbind(df_data, 
                   data.frame(name = "PPI inflation construction",
                              mnemonic = "ppi_constr",
                              category = "prices",
                              group = "prices",
                              trafo = "log, diff",
                              frequency = "Q",
                              code = "BBKRT.Q.DE.N.P.PP1.PP300.R.I",
                              code_deflate = NA 
                              )
                   )  

  df_data <- rbind(df_data, 
                   data.frame(name = "PPI inflation agriculture",
                              mnemonic = "ppi_agri",
                              category = "prices",
                              group = "prices",
                              trafo = "log, diff",
                              frequency = "M",
                              code = "BBKRT.M.DE.S.P.PP1.PP400.R.I",
                              code_deflate = NA 
                              )
                   )  

  #######################################################################################
  # monthly activity indicators
  #######################################################################################
  
  df_data <- rbind(df_data, 
                   data.frame(name = "production industry",
                              mnemonic = "prod_ind",
                              category = "activity",
                              group = "activity",
                              trafo = "log, diff",
                              frequency = "M",
                              code =  "BBKRT.M.DE.Y.I.IP1.AA020.C.I",
                              code_deflate = NA 
                              )
                  )

  df_data <- rbind(df_data, 
                   data.frame(name = "production construction",
                              mnemonic = "prod_constr",
                              category = "activity",
                              group = "activity",
                              trafo = "log, diff",
                              frequency = "M",
                              code =  "BBKRT.M.DE.Y.I.IP1.AA020.C.I",
                              code_deflate = NA 
                              )
                  )
  
  df_data <- rbind(df_data, 
                   data.frame(name = "orders industry",
                              mnemonic = "ord",
                              category = "activity",
                              group = "activity",
                              trafo = "log, diff",
                              frequency = "M",
                              code =  "BBKRT.M.DE.Y.I.IO1.ACM01.C.I",
                              code_deflate = NA 
                              )
                  )

  df_data <- rbind(df_data, 
                   data.frame(name = "orders construction",
                              mnemonic = "ord_constr",
                              category = "activity",
                              group = "activity",
                              trafo = "log, diff",
                              frequency = "M",
                              code =  "BBKRT.M.DE.Y.I.IO1.AA031.C.I",
                              code_deflate = NA 
                              )
                  )

  df_data <- rbind(df_data, 
                   data.frame(name = "turnover industry",
                              mnemonic = "to",
                              category = "activity",
                              group = "activity",
                              trafo = "log, diff",
                              frequency = "M",
                              code =  "BBKRT.M.DE.Y.I.IT1.ACM01.V.I",
                              code_deflate = NA 
                              )
                  )
  

  df_data <- rbind(df_data, 
                   data.frame(name = "turnover retail",
                              mnemonic = "to_retail",
                              category = "activity",
                              group = "activity",
                              trafo = "log, diff",
                              frequency = "M",
                              code =  "BBKRT.M.DE.Y.I.IT1.AGA01.C.I",
                              code_deflate = NA 
                              )
                  )

  df_data <- rbind(df_data, 
                   data.frame(name = "turnover construction",
                              mnemonic = "to_constr",
                              category = "activity",
                              group = "activity",
                              trafo = "log, diff",
                              frequency = "M",
                              code =  "BBKRT.M.DE.Y.I.IT1.AA031.V.A",
                              code_deflate = NA 
                              )
                  )

  #######################################################################################
  # labor market
  #######################################################################################

  df_data <- rbind(df_data, 
                   data.frame(name = "employment",
                              mnemonic = "emp",
                              category = "labor market",
                              group = "labor market",
                              trafo = "log, diff",
                              frequency = "Q",
                              code =  "BBKRT.Q.DE.S.A.BF1.CA010.P.A",
                              code_deflate = NA 
                              )
                  )
  df_data <- rbind(df_data, 
                   data.frame(name = "hours worked industry",
                              mnemonic = "h_ind",
                              category = "labor market",
                              group = "labor market",
                              trafo = "log, diff",
                              frequency = "M",
                              code =  "BBKRT.M.DE.Y.L.BE2.AA022.H.I",
                              code_deflate = NA 
                              )
                  )  
  
  df_data <- rbind(df_data, 
                   data.frame(name = "hours worked constr",
                              mnemonic = "h_constr",
                              category = "labor market",
                              group = "labor market",
                              trafo = "log, diff",
                              frequency = "M",
                              code =  "BBKRT.M.DE.Y.L.BE2.AA031.H.A",
                              code_deflate = NA 
                   )
  )  

  df_data <- rbind(df_data, 
                   data.frame(name = "wages",
                              mnemonic = "w",
                              category = "labor market",
                              group = "labor market",
                              trafo = "log, diff",
                              frequency = "Q",
                              code =  "BBKRT.Q.DE.S.A.DE2.CA010.V.A",
                              code_deflate = NA 
                              )
                  ) 

  return(df_data)
}