run these to setup workspace:

alpha = 2;
W = 200;
segmentedClumps = segmentClumps('EDF000.png', nucleusMask, 1000);
nucleusMask = segmentNuclei("EDF000.png", 50, 0.95, 10, 210, 2.5);