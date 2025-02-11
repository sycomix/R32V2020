#!/usr/bin/env python

import unittest
import assembler

class StripCommentsSpecs(unittest.TestCase):
  def test_empty_strings_have_no_comments_to_strip(self):
    self.assertEqual(assembler.stripComments(''), '')

  def test_lines_with_only_a_comment_strip_the_comment_out(self):
    self.assertEqual(assembler.stripComments('; foo'), '')

  def test_lines_followed_by_a_comment_strip_the_comment_out(self):
    self.assertEqual(assembler.stripComments('add r10,r11,r12; foo'), 'add r10,r11,r12')

  def test_comments_after_strings_are_stripped_out(self):
    self.assertEqual(assembler.stripComments('hi: .string "foo bar" ; comment'), 'hi: .string "foo bar" ')

  def test_semicolons_in_strings_are_not_stripped_out(self):
    self.assertEqual(assembler.stripComments('hi: .string "foo; bar"'), 'hi: .string "foo; bar"')

  def test_semicolons_in_strings_are_not_thrown_off_by_escaped_double_quotes(self):
    self.assertEqual(assembler.stripComments('hi: .string "foo; \\" ; bar"'), 'hi: .string "foo; \\" ; bar"')

class FormatHexSpecs(unittest.TestCase):
  def test_a_case_that_looks_like_an_add_instruction_at_addres_0_works(self):
    resolver = assembler.BinDestResolver(32, 7, 0, 0)
    self.assertTrue(assembler.formatInstructionHex(0, resolver, {}, {}).startswith(':0400000020700000'))

  def test_a_result_has_the_correct_length(self):
    resolver = assembler.BinDestResolver(32, 7, 0, 0)
    self.assertEqual(len(assembler.formatInstructionHex(0, resolver, {}, {})), 19)

  def test_checksum_value_itself_is_correct(self):
    self.assertEqual(assembler.checksum(int('040000002070000000', 16)), 108)

  def test_checksum_value_itself_is_correct_example_2(self):
    self.assertEqual(assembler.checksum(int('040010001122334400', 16)), 66)

  def test_the_checksum_bits_are_correct(self):
    resolver = assembler.BinDestResolver(32, 7, 0, 0)
    self.assertEqual(assembler.formatInstructionHex(0, resolver, {}, {})[-2:], '6C')

  def test_the_address_is_encoded(self):
    resolver = assembler.BinDestResolver(32, 7, 0, 0)
    address = 4267
    answer = assembler.formatInstructionHex(address, resolver, {}, {})
    self.assertEqual(answer[3:7], '10AB')

class TwosCompSpecs(unittest.TestCase):
  def test_negative_one(self):
    self.assertEqual(assembler.twosComp24(1), int('1'*24, 2))

class RegisterParsingAndValidationSpecs(unittest.TestCase):
  def test_rNs_are_valid_registers_from_0_to_15(self):
    for i in xrange(0, 16):
      self.assertTrue(assembler.isValidRegister('r' + str(i)))

  def test_r16_is_not_a_valid_register(self):
    self.assertFalse(assembler.isValidRegister('r16'))

  def test_rNs_just_parse_as_N(self):
    for i in xrange(0, 16):
      self.assertEqual(assembler.parseRegister('r' + str(i)), i)

  def test_ZERO_is_a_valid_register(self):
    self.assertTrue(assembler.isValidRegister('ZERO'))

  def test_ZERO_is_an_alias_for_r0(self):
    for valid in ['zero', 'ZERO', 'zErO']:
      self.assertEqual(assembler.parseRegister(valid), 0)

  def test_ONE_is_a_valid_register(self):
    self.assertTrue(assembler.isValidRegister('ONE'))

  def test_ONE_is_an_alias_for_r1(self):
    for valid in ['one', 'ONE', 'OnE']:
      self.assertEqual(assembler.parseRegister(valid), 1)

  def test_MINUS1_is_a_valid_register(self):
    self.assertTrue(assembler.isValidRegister('MINUS1'))

  def test_MINUS1_is_an_alias_for_r2(self):
    for valid in ['minus1', 'MINuS1']:
      self.assertEqual(assembler.parseRegister(valid), 2)

  def test_CCR_is_a_valid_register(self):
    self.assertTrue(assembler.isValidRegister('CCR'))

  def test_CCR_is_an_alias_for_r3(self):
    for valid in ['ccr', 'CCR']:
      self.assertEqual(assembler.parseRegister(valid), 3)

  def test_SAR_is_a_valid_register(self):
    self.assertTrue(assembler.isValidRegister('SAR'))

  def test_SAR_is_an_alias_for_r4(self):
    for valid in ['sar', 'SAR']:
      self.assertEqual(assembler.parseRegister(valid), 4)

  def test_PAR_is_a_valid_register(self):
    self.assertTrue(assembler.isValidRegister('PAR'))

  def test_PAR_is_an_alias_for_r5(self):
    for valid in ['par', 'PAR']:
      self.assertEqual(assembler.parseRegister(valid), 5)

  def test_DAR_is_a_valid_register(self):
    self.assertTrue(assembler.isValidRegister('DAR'))

  def test_DAR_is_an_alias_for_r6(self):
    for valid in ['dar', 'DAR']:
      self.assertEqual(assembler.parseRegister(valid), 6)

  def test_PC_is_a_valid_register(self):
    self.assertTrue(assembler.isValidRegister('DAR'))

  def test_PC_is_an_alias_for_r7(self):
    for valid in ['pc', 'PC']:
      self.assertEqual(assembler.parseRegister(valid), 7)

  def test_GP0_through_GP7_are_valid_registers(self):
    for i in xrange(0, 8):
      self.assertTrue(assembler.isValidRegister('GP' + str(i)))

  def test_GPN_is_an_alias_for_rN_plus_8(self):
    for i in xrange(0, 8):
      self.assertEqual(assembler.parseRegister('GP' + str(i)), i+8)

  def test_GP8_is_not_a_valid_register(self):
    self.assertFalse(assembler.isValidRegister('GP8'))

class ValidAddressSpecs(unittest.TestCase):
  def test_lower_is_valid(self):
    self.assertTrue(assembler.isValidAddress('hi'))

  def test_upper_is_valid(self):
    self.assertTrue(assembler.isValidAddress('HI'))

  def test_numbers_alone_are_valid(self):
    self.assertTrue(assembler.isValidAddress('42'))

  def test_underscores_are_valid(self):
    self.assertTrue(assembler.isValidAddress('____'))

  def test_intermixing_is_valid(self):
    self.assertTrue(assembler.isValidAddress('test_BCC_BCS_42'))

class ValidDataLabelReferenceSpecs(unittest.TestCase):
  def test_lowercase_upper_reference_is_valid(self):
    self.assertTrue(assembler.isValidDataLabelReference('label.upper'))

  def test_lowercase_lower_reference_is_valid(self):
    self.assertTrue(assembler.isValidDataLabelReference('label.lower'))

  def test_mixed_case_lower_reference_is_valid(self):
    self.assertTrue(assembler.isValidDataLabelReference('LaBel.LoWer'))

  def test_stuff_that_usually_works_in_labels_works_in_the_reference(self):
    self.assertTrue(assembler.isValidDataLabelReference('lAb3l__hi42.LoWer'))

class DataHexFormatSpecs(unittest.TestCase):
  def test_formatting_a_simple_string_constant(self):
    results = assembler.StringConstant('"Hell"').resolveHex()
    self.assertEqual(assembler.formatDataHex(0, results[0]), ':0400000048656C6C77')

  def test_full_hello_world_works(self):
    expected = [
      ':0400000048656C6C77',
      ':040001006F2C2057E9',
      ':040002006F726C6449',
      ':0400030000000000F9'
    ]

    results = assembler.StringConstant('"Hello, World"').resolveHex()

    lines = []

    for (i, result) in enumerate(results):
      lines.append(assembler.formatDataHex(i, result))

    self.assertEqual(lines, expected)

  def test_three_character_strings_dont_flow_into_the_next_line(self):
    results = assembler.StringConstant('"Hel"').resolveHex()
    self.assertEqual(len(results), 1)

  def test_three_character_strings_are_automatically_null_terminated(self):
    results = assembler.StringConstant('"Hel"').resolveHex()
    self.assertEqual(assembler.formatDataHex(0, results[0])[-4:-2], '00')

  def test_padding_adds_zeroes_to_the_right(self):
    results = assembler.StringConstant('"H"').resolveHex()
    self.assertEqual(assembler.formatDataHex(0, results[0])[:-2], ':0400000048000000')

  def test_byte_filling_works(self):
    results = assembler.ByteConstant([1, 2, 3, 4]).resolveHex()
    self.assertEqual(assembler.formatDataHex(0, results[0])[:-2], ':0400000001020304')

  def test_short_filling_works(self):
    results = assembler.ShortConstant([10, 17]).resolveHex()
    self.assertEqual(assembler.formatDataHex(0, results[0])[:-2], ':04000000000A0011')

  def test_short_filling_works(self):
    results = assembler.ShortConstant([10, 17]).resolveHex()
    self.assertEqual(assembler.formatDataHex(0, results[0])[:-2], ':04000000000A0011')

  def test_long_filling_works(self):
    results = assembler.LongConstant('0xAB15C').resolveHex()
    self.assertEqual(assembler.formatDataHex(0, results[0])[:-2], ':04000000000AB15C')

if __name__ == '__main__':
  unittest.main()
