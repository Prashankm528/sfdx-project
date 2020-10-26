/****************************************************************************************************
 *  Date          : 18-JUN-2020
 *  Author        : Sunny Yap
 *  Description   : Program that verifies the checksum of a Payment Card Number.
 *  Modifications : 18-JUN-2020 SYAP - Initial
 ****************************************************************************************************/

public with sharing class GCM_PCI_Check {
/****************************************************************************************************
  Verify Payment Card Number Check Sum
  Returns true If Payment Card Number Passed Checksum
 ****************************************************************************************************/
    public static boolean verifyCardNumber(String cardNumber) {
        Integer sum = 0;
        Integer cardLength = cardNumber.length();
        for (Integer count = cardLength - 1; count >= 0; count--){
            Integer digit = Integer.valueOf(cardNumber.substring(count, count + 1));
            if (Math.mod(count , 2) == Math.mod(cardLength, 2)) {
                Integer multiplied = digit * 2;
                sum += (multiplied / 10) + (Math.mod(multiplied, 10));
            }
            else {
                sum += digit;
            }
        }
        return Math.mod(sum, 10) == 0;    
    }
}