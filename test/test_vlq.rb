require 'minitest/autorun'
require 'source_map/vlq'

class TestVLQ < MiniTest::Test
  include SourceMap

  TESTS = {
    'A'          => [0],
    'C'          => [1],
    'D'          => [-1],
    'E'          => [2],
    'F'          => [-2],
    'K'          => [5],
    'L'          => [-5],
    'w+B'        => [1000],
    'x+B'        => [-1000],
    'gqjG'       => [100000],
    'hqjG'       => [-100000],
    'AAgBC'      => [0, 0, 16, 1],
    'AAgCgBC'    => [0, 0, 32, 16, 1],
    'DFLx+BhqjG' => [-1, -2, -5, -1000, -100000],
    'CEKw+BgqjG' => [1, 2, 5, 1000, 100000]
  }

  MAP_TESTS = {
    'AA,AA;;AACDE' => [[[0, 0], [0, 0]], [], [[0, 0, 1, -1, 2]]],
    ';;;;EAEE,EAAE,EAAC,CAAE;ECQY,UACC' => [[], [], [], [], [[2, 0, 2, 2], [2, 0, 0, 2], [2, 0, 0, 1], [1, 0, 0, 2]], [[2, 1, 8, 12], [10, 0, 1, 1]]],
    'AAEAA,QAASA,MAAK,EAAG,CACfC,OAAAC,IAAA,CAAY,eAAZ,CADe' => [[[0, 0, 2, 0, 0], [8, 0, 0, 9, 0], [6, 0, 0, 5], [2, 0, 0, 3], [1, 0, 1, -15, 1], [7, 0, 0, 0, 1], [4, 0, 0, 0], [1, 0, 0, 12], [15, 0, 0, -12], [1, 0, -1, 15]]],
    ';;;;;EACAA;;EACAC;;EAGA;IAAA;;;EAGAC;IAAS;;;EAGTC;;EAGAC;IACE;IACA;IACA;MAAQ;;;;EAGVC;;;IACE;;;EAGF;IAAA;;;EAGAC;;;IAAQ;;MAAA' => [[], [], [], [], [], [[2, 0, 1, 0, 0]], [], [[2, 0, 1, 0, 1]], [], [[2, 0, 3, 0]], [[4, 0, 0, 0]], [], [], [[2, 0, 3, 0, 1]], [[4, 0, 0, 9]], [], [], [[2, 0, 3, -9, 1]], [], [[2, 0, 3, 0, 1]], [[4, 0, 1, 2]], [[4, 0, 1, 0]], [[4, 0, 1, 0]], [[6, 0, 0, 8]], [], [], [], [[2, 0, 3, -10, 1]], [], [], [[4, 0, 1, 2]], [], [], [[2, 0, 3, -2]], [[4, 0, 0, 0]], [], [], [[2, 0, 3, 0, 1]], [], [], [[4, 0, 0, 8]], [], [[6, 0, 0, 0]]],
    'AACC,SAAQ,EAAG,CAAA,IACCA,CADD,CACOC,CADP,CACaC,CADb,CAC0CC,CAWpDA,EAAA,CAASA,QAAQ,CAACC,CAAD,CAAI,CACnB,MAAOA,EAAP,CAAWA,CADQ,CAIrBJ,EAAA,CAAO,CAAC,CAAD,CAAI,CAAJ,CAAO,CAAP,CAAU,CAAV,CAAa,CAAb,CAEPC,EAAA,CAAO,MACCI,IAAAC,KADD,QAEGH,CAFH,MAGCI,QAAQ,CAACH,CAAD,CAAI,CAChB,MAAOA,EAAP,CAAWD,CAAA,CAAOC,CAAP,CADK,CAHb,CAcc,YAArB,GAAI,MAAOI,MAAX,EAA8C,IAA9C,GAAoCA,KAApC,EACEC,KAAA,CAAM,YAAN,CAGO,UAAQ,EAAG,CAAA,IACdC,CADc,CACVC,CADU,CACJC,CACdA,EAAA,CAAW,EACNF,EAAA,CAAK,CAAV,KAAaC,CAAb,CAAoBX,CAAAa,OAApB,CAAiCH,CAAjC,CAAsCC,CAAtC,CAA4CD,CAAA,EAA5C,CACER,CACA,CADMF,CAAA,CAAKU,CAAL,CACN,CAAAE,CAAAE,KAAA,CAAcb,CAAAM,KAAA,CAAUL,CAAV,CAAd,CAEF,OAAOU,EAPW,CAAX,CAAA,EApCC,CAAX,CAAAG,KAAA,CA8CO,IA9CP' => [[[0, 0, 1, 1], [9, 0, 0, 8], [2, 0, 0, 3], [1, 0, 0, 0], [4, 0, 1, 1, 0], [1, 0, -1, -1], [1, 0, 1, 7, 1], [1, 0, -1, -7], [1, 0, 1, 13, 1], [1, 0, -1, -13], [1, 0, 1, 42, 1], [1, 0, 11, -52, 0], [2, 0, 0, 0], [1, 0, 0, 9, 0], [8, 0, 0, 8], [1, 0, 0, 1, 1], [1, 0, 0, -1], [1, 0, 0, 4], [1, 0, 1, -19], [6, 0, 0, 7, 0], [2, 0, 0, -7], [1, 0, 0, 11, 0], [1, 0, -1, 8], [1, 0, 4, -21, -4], [2, 0, 0, 0], [1, 0, 0, 7], [1, 0, 0, 1], [1, 0, 0, -1], [1, 0, 0, 4], [1, 0, 0, -4], [1, 0, 0, 7], [1, 0, 0, -7], [1, 0, 0, 10], [1, 0, 0, -10], [1, 0, 0, 13], [1, 0, 0, -13], [1, 0, 2, -7, 1], [2, 0, 0, 0], [1, 0, 0, 7], [6, 0, 1, 1, 4], [4, 0, 0, 0, 1], [5, 0, -1, -1], [8, 0, 2, 3, -3], [1, 0, -2, -3], [6, 0, 3, 1, 4], [8, 0, 0, 8], [1, 0, 0, 1, -3], [1, 0, 0, -1], [1, 0, 0, 4], [1, 0, 1, -16], [6, 0, 0, 7, 0], [2, 0, 0, -7], [1, 0, 0, 11, -1], [1, 0, 0, 0], [1, 0, 0, 7, 1], [1, 0, 0, -7], [1, 0, -1, 5], [1, 0, -3, -13], [1, 0, 14, 14], [12, 0, 0, -21], [3, 0, 0, 4], [6, 0, 0, 7, 4], [6, 0, 0, -11], [2, 0, 0, 46], [4, 0, 0, -46], [3, 0, 0, 36, 0], [5, 0, 0, -36], [2, 0, 1, 2, 1], [5, 0, 0, 0], [1, 0, 0, 6], [12, 0, 0, -6], [1, 0, 3, 7], [10, 0, 0, 8], [2, 0, 0, 3], [1, 0, 0, 0], [4, 0, 1, -14, 1], [1, 0, -1, 14], [1, 0, 1, -10, 1], [1, 0, -1, 10], [1, 0, 1, -4, 1], [1, 0, 1, -14, 0], [2, 0, 0, 0], [1, 0, 0, 11], [2, 0, 1, -6, -2], [2, 0, 0, 0], [1, 0, 0, 5], [1, 0, 0, -10], [5, 0, 0, 13, 1], [1, 0, 0, -13], [1, 0, 0, 20, -11], [1, 0, 0, 0, 13], [7, 0, 0, -20], [1, 0, 0, 33, -3], [1, 0, 0, -33], [1, 0, 0, 38, 1], [1, 0, 0, -38], [1, 0, 0, 44, -1], [1, 0, 0, 0], [2, 0, 0, -44], [1, 0, 1, 2, -8], [1, 0, 1, 0], [1, 0, -1, 6, -2], [1, 0, 0, 0], [1, 0, 0, 5, 10], [1, 0, 0, -5], [1, 0, 1, -6], [1, 0, 0, 0, 2], [1, 0, 0, 0, 2], [5, 0, 0, 0], [1, 0, 0, 14, -13], [1, 0, 0, 0, 6], [5, 0, 0, 0], [1, 0, 0, 10, -5], [1, 0, 0, -10], [1, 0, 0, -14], [1, 0, 2, -2], [7, 0, 0, 7, 10], [2, 0, -7, 11], [1, 0, 0, -11], [1, 0, 0, 0], [2, 0, -36, 1], [1, 0, 0, -11], [1, 0, 0, 0, 3], [5, 0, 0, 0], [1, 0, 46, 7], [4, 0, -46, -7]]]
  }

  def test_encode
    TESTS.each do |str, int|
      assert_equal str, VLQ.encode(int)
    end
  end

  def test_decode
    TESTS.each do |str, int|
      assert_equal int, VLQ.decode(str)
    end
  end

  def test_encode_decode
    (-255..255).each do |int|
      assert_equal [int], VLQ.decode(VLQ.encode([int]))
    end
  end

  def test_encode_mappings
    MAP_TESTS.each do |str, ary|
      assert_equal str, VLQ.encode_mappings(ary)
    end
  end

  def test_decode_mappings
    MAP_TESTS.each do |str, ary|
      assert_equal ary, VLQ.decode_mappings(str)
    end
  end
end
