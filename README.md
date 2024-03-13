# Congestion-Management using a VAR Compensation
Demonstration of Congestion Management in a Simple MV Network using OpenDSS via COM Interface Through MATLAB Algorithm

Congestion management is a vital part of power system operations in the realm of Low Carbon Technologies. In this work, I analysed the impact of distributed generator and developed control algorithm for VAR compensation through MATLAB with OpenDSS co-simulation on line congestion of simple MV network.

~ Formulation of congested line and its representation (Yearly data)

~ Impact of distributed generator on line congestion

~ Control of VAR compensation based on hourly time series analysis


# Steps to compute results:
1) All files should be saved in the folder with directory without spaces (e.g: C:/my_work/congestion_management)

2) Normal Operation: Comment the sections title "Creating Problem, Implementing Solution" and run
   Note: The line does't show any congestion
4) Line Congestion (Increasing Load by factor):  Uncomment the section "Creating Problem" and run
   Note: Increasing load by defined factor cause violation of capacity limits
6) Inserting Distribution Generator: Uncomment the lines with title distribution generator and run
   Note: Addition of distributed generator lower the capcity violation but line has still issues
7) Using VAR Compensation: Uncomment the VAR compensation loop while comenting the lines associated for normal operation and run
   Note: There is improved results but line has still congestion(Room for Improvement)
