require 'test_helper'

class CodeobscureTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Codeobscure::VERSION
  end

  def test_it_funclist_capture
    result = FuncList.capture '+ (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view' 
    assert_equal result , ['pickerView','viewForRow','forComponent','reusingView']
  end

  def test_it_funclist_genFuncList
    test_dir = "#{File.dirname(__FILE__)}/objcTemple"
    funclist_path = "#{test_dir}/func.list"
    if File.exist? funclist_path
      File.delete funclist_path
    end
    FuncList.genFuncList(test_dir)
    is_exist = File.exist? funclist_path
    assert is_exist , "generate func.list file failed"
    
    content = File.read funclist_path
    expect_result = "addItem\ngetClusters\ngetRectWithPt\nSpan\ngetDistanceSquared\npoint"
    assert_equal expect_result , content 
  end


end
