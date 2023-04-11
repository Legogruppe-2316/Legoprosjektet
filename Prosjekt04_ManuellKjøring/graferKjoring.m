lysThomas= [28	28	28	28	28	31	29	30	45	54	44	25	21	22	11	9	10	17	14	9	9	17	19	10	11	21	42	44	47	38	24	14	11	11	13	19	4	3	4	4	4];
lysChristopher=[33	33	33	20	22	25	28	33	30	21	15	14	17	21	21	21	29	35	20	12	13	35	49	32	14	14	22	21	17	17	20	17	11	67];
lysGard = [17	22	23	25	29	31	31	37	38	34	30	27	26	27	27	30	35	23	11	9	11	12	17	11	9	14	26	36	27	18	26	28	32	33	17	21	25	18	15	21	71];
lysLanny = [25	25	25	26	26	24	23	24	22	25	27	26	29	32	32	27	27	28	29	30	29	21	15	16	24	32	30	32	37	35	27	22	22	27	20	22	30	31	18	16	14	13	12	9	10	37	69];

subplot(2,2,1);
histogram(lysThomas);
title('Thomas, mean=21.46, std=13.59');
xlim([0,60]);
ylim([0,30]);

subplot(2,2,2);
histogram(lysChristopher);
title('Christopher, mean=24.4, std=11');
xlim([0,60]);
ylim([0,30]);

subplot(2,2,3);
histogram(lysGard);
title('Gard, mean=25, std=11');
xlim([0,60]);
ylim([0,30]);

subplot(2,2,4);
histogram(lysLanny);
title('Lanni, mean=25.57, std=9.33');
xlim([0,60]);
ylim([0,30]);

drawnow