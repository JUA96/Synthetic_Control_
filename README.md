# Synthetic Control Method

Synthetic control methods are a relatively new addition to the roster of causal inference techniques used in applied political science work.
The best place to start reading therefore is this article by Abadie et al (2015) in the American Journal of Political Science.

## The effect of Economic and Monetary Union on Current Account Balances – Hope (2016)

In early 2008, about a decade after the Euro was first introduced, the European Commission published a document looking back at the currency’s short history and concluded that the European Economic and Monetary Union was a “resounding success”. By the end of 2009 Europe was at the beginning of a multiyear sovereign debt crisis, in which several countries – including a number of Eurozone members – were unable to repay or refinance their government debt or to bail out over-indebted banks. Although the causes of the Eurocrisis were many and varied, one aspect of the pre-crisis era that became particularly damaging after 2008 were the large and persistent current account deficits of many member states. Current account imbalances – which capture the inflows and outflows of both goods and services and investment income – were a marked feature of the post-EMU, pre-crisis era, with many countries in the Eurozone running persistent current account deficits (indicating that they were net borrowers from the rest of the world). Large current account deficits make economies more vulnerable to external economic shocks because of the risk of a sudden stop in capital used to finance government deficits.

David Hope investigates the extent to which the introduction of the Economic and Monetary Union in 1999 was responsible for the current account imbalances that emerged in the 2000s. Using the sythetic control method, Hope evaluates the causal effect of EMU on current account balances in 11 countries between 1980 and 2010. In this exercise, we will focus on just one country – Spain – and evaluate the causal effect of joining EMU on the Spanish current account balance. 

In this case, the donor pool consists of 15 OECD countries that did not join the EMU: Australia, Canada, Chile, Denmark, Hungary, Israel, Japan, Korea, Mexico, New Zealand, Poland, Sweden, Turkey, the UK and the US.

The hope_emu.csv file contains data on these 16 countries across the years 1980 to 2010. The data includes the following variables:

1. period – the year of observation
2. country_ID – the country of observation
3. country_no – a numeric country identifier
4. CAB – current account balance
5. GDPPC_PPP – GDP per capita, purchasing power adjusted
6. invest – Total investment as a % of GDP
7. gov_debt – Government debt as a % of GDP
8. openness – trade openness
9. demand – domestic demand growth
10. x_price – price level of exports
11. gov_deficit – Government primary balance as a % of GDP
12. credit – domestic credit to the private sector as a % of GDP
13. GDP_gr – GDP growth %
