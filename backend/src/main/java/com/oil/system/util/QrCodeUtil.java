package com.oil.system.util;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

public class QrCodeUtil {

    private static final int WIDTH = 300;
    private static final int HEIGHT = 300;

    /**
     * 生成二维码
     * @param content 二维码内容
     * @param savePath 保存路径
     * @return 二维码文件路径
     */
    public static String generateQrCode(String content, String savePath) {
        try {
            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
            hints.put(EncodeHintType.MARGIN, 1);

            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            BitMatrix bitMatrix = qrCodeWriter.encode(content, BarcodeFormat.QR_CODE, WIDTH, HEIGHT, hints);

            String fileName = content + ".png";
            Path path = FileSystems.getDefault().getPath(savePath, fileName);
            MatrixToImageWriter.writeToPath(bitMatrix, "PNG", path);

            return path.toString();
        } catch (WriterException | IOException e) {
            throw new RuntimeException("生成二维码失败", e);
        }
    }
}
