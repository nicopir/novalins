require 'test_helper'

class InputFilesControllerTest < ActionController::TestCase
  setup do
    @input_file = input_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:input_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create input_file" do
    assert_difference('InputFile.count') do
      post :create, input_file: { file_path: @input_file.file_path, project_id: @input_file.project_id }
    end

    assert_redirected_to input_file_path(assigns(:input_file))
  end

  test "should show input_file" do
    get :show, id: @input_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @input_file
    assert_response :success
  end

  test "should update input_file" do
    patch :update, id: @input_file, input_file: { file_path: @input_file.file_path, project_id: @input_file.project_id }
    assert_redirected_to input_file_path(assigns(:input_file))
  end

  test "should destroy input_file" do
    assert_difference('InputFile.count', -1) do
      delete :destroy, id: @input_file
    end

    assert_redirected_to input_files_path
  end
end
