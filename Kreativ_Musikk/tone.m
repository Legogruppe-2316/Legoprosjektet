function tone = mapGrayScaleToTone(grayScaleValue)
    load("tonedata.mat")
    if (grayScaleValue <= 5)
        tone = ToneData(1);
        return;
    elseif (grayScaleValue <= 6)
        tone = ToneData(2);
        return;
    elseif (grayScaleValue <= 9)
        tone = ToneData(3);
        return;
    elseif (grayScaleValue <= 11)
        tone = ToneData(4);
        return;
    elseif (grayScaleValue <= 17)
        tone = ToneData(5);
        return;
    elseif (grayScaleValue <= 29)
        tone = ToneData(6);
        return;
    end
    greyScaleValue = grayScaleValue/33;
    index = round(greyScaleValue * (length(ToneData) - 1)) + 1;
    tone = ToneData(index);
end
