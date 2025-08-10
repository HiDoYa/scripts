import pytest
import tempfile
import os
import json
import xml.etree.ElementTree as ET
from unittest.mock import patch, mock_open
import toml

from vupdate import (
    ProjectVersionTypes,
    find_project_type,
    get_current_version,
    find_version_file,
    find_gemspec_file,
    find_project_file,
    get_version_file_prefix,
)


class TestProjectVersionTypes:
    def test_all_project_types_exist(self):
        expected_types = [
            ProjectVersionTypes.UV,
            ProjectVersionTypes.POETRY,
            ProjectVersionTypes.VERSION,
            ProjectVersionTypes.NODE_PACKAGE_JSON,
            ProjectVersionTypes.RUST_CARGO,
            ProjectVersionTypes.GO_MOD,
            ProjectVersionTypes.RUBY_GEMSPEC,
            ProjectVersionTypes.DOTNET_CSPROJ,
            ProjectVersionTypes.DOTNET_FSPROJ,
        ]
        assert len(expected_types) == 9


class TestFindProjectType:
    def test_uv_project_type(self):
        with patch('os.path.isfile') as mock_isfile:
            mock_isfile.side_effect = lambda f: f == "uv.lock"
            assert find_project_type() == ProjectVersionTypes.UV

    def test_poetry_project_type(self):
        with patch('os.path.isfile') as mock_isfile:
            mock_isfile.side_effect = lambda f: f == "poetry.lock"
            assert find_project_type() == ProjectVersionTypes.POETRY

    def test_node_project_type(self):
        with patch('os.path.isfile') as mock_isfile:
            mock_isfile.side_effect = lambda f: f == "package.json"
            assert find_project_type() == ProjectVersionTypes.NODE_PACKAGE_JSON

    def test_rust_project_type(self):
        with patch('os.path.isfile') as mock_isfile:
            mock_isfile.side_effect = lambda f: f == "Cargo.toml"
            assert find_project_type() == ProjectVersionTypes.RUST_CARGO

    def test_go_project_type(self):
        with patch('os.path.isfile') as mock_isfile:
            mock_isfile.side_effect = lambda f: f == "go.mod"
            assert find_project_type() == ProjectVersionTypes.GO_MOD

    def test_ruby_gemspec_project_type(self):
        with patch('os.path.isfile') as mock_isfile, \
             patch('os.listdir') as mock_listdir:
            # Mock specific file checks to return False for priority files
            mock_isfile.side_effect = lambda f: f.endswith('.gemspec')
            mock_listdir.return_value = ["test.gemspec", "other.file"]
            assert find_project_type() == ProjectVersionTypes.RUBY_GEMSPEC

    def test_dotnet_csproj_project_type(self):
        with patch('os.path.isfile') as mock_isfile, \
             patch('os.listdir') as mock_listdir:
            mock_isfile.side_effect = lambda f: f.endswith('.csproj')
            mock_listdir.return_value = ["test.csproj", "other.file"]
            assert find_project_type() == ProjectVersionTypes.DOTNET_CSPROJ

    def test_dotnet_fsproj_project_type(self):
        with patch('os.path.isfile') as mock_isfile, \
             patch('os.listdir') as mock_listdir:
            mock_isfile.side_effect = lambda f: f.endswith('.fsproj')
            mock_listdir.return_value = ["test.fsproj", "other.file"]
            assert find_project_type() == ProjectVersionTypes.DOTNET_FSPROJ

    def test_version_file_fallback(self):
        with patch('os.path.isfile') as mock_isfile, \
             patch('os.listdir') as mock_listdir:
            mock_isfile.return_value = False
            mock_listdir.return_value = []
            assert find_project_type() == ProjectVersionTypes.VERSION


class TestGetCurrentVersion:
    @patch('vupdate.run_command')
    def test_uv_version(self, mock_run):
        mock_run.return_value = "1.2.3"
        version = get_current_version(ProjectVersionTypes.UV)
        assert version == "1.2.3"
        mock_run.assert_called_with("uv version --short")

    @patch('vupdate.run_command')
    def test_poetry_version(self, mock_run):
        mock_run.return_value = "2.3.4"
        version = get_current_version(ProjectVersionTypes.POETRY)
        assert version == "2.3.4"
        mock_run.assert_called_with("poetry version -s")

    def test_version_file(self):
        with patch('builtins.open', mock_open(read_data="1.0.0\n")):
            version = get_current_version(ProjectVersionTypes.VERSION, "VERSION")
            assert version == "1.0.0"

    def test_version_file_with_v_prefix(self):
        with patch('builtins.open', mock_open(read_data="v1.0.0\n")):
            version = get_current_version(ProjectVersionTypes.VERSION, "VERSION")
            assert version == "1.0.0"

    def test_node_package_json(self):
        package_data = {"name": "test", "version": "3.4.5"}
        with patch('builtins.open', mock_open(read_data=json.dumps(package_data))):
            version = get_current_version(ProjectVersionTypes.NODE_PACKAGE_JSON)
            assert version == "3.4.5"

    def test_node_package_json_no_version(self):
        package_data = {"name": "test"}
        with patch('builtins.open', mock_open(read_data=json.dumps(package_data))):
            version = get_current_version(ProjectVersionTypes.NODE_PACKAGE_JSON)
            assert version == "0.1.0"

    def test_rust_cargo(self):
        cargo_data = {"package": {"version": "4.5.6"}}
        with patch('builtins.open', mock_open(read_data=toml.dumps(cargo_data))):
            version = get_current_version(ProjectVersionTypes.RUST_CARGO)
            assert version == "4.5.6"

    def test_go_mod_with_version(self):
        go_mod_content = "module example.com/foo/v2\n\ngo 1.21\n"
        with patch('builtins.open', mock_open(read_data=go_mod_content)):
            version = get_current_version(ProjectVersionTypes.GO_MOD)
            assert version == "2.0.0"

    def test_go_mod_without_version(self):
        go_mod_content = "module example.com/foo\n\ngo 1.21\n"
        with patch('builtins.open', mock_open(read_data=go_mod_content)):
            with pytest.raises(Exception, match="No version found"):
                get_current_version(ProjectVersionTypes.GO_MOD)

    @patch('vupdate.find_gemspec_file')
    def test_ruby_gemspec(self, mock_find):
        mock_find.return_value = "test.gemspec"
        gemspec_content = 'Gem::Specification.new do |spec|\n  spec.version = "5.6.7"\nend'
        with patch('builtins.open', mock_open(read_data=gemspec_content)):
            version = get_current_version(ProjectVersionTypes.RUBY_GEMSPEC)
            assert version == "5.6.7"

    @patch('vupdate.find_gemspec_file')
    def test_ruby_gemspec_no_file(self, mock_find):
        mock_find.return_value = None
        with pytest.raises(Exception, match="No version found"):
            get_current_version(ProjectVersionTypes.RUBY_GEMSPEC)

    @patch('vupdate.find_project_file')
    def test_dotnet_csproj(self, mock_find):
        mock_find.return_value = "test.csproj"
        xml_content = '''<?xml version="1.0" encoding="utf-8"?>
        <Project Sdk="Microsoft.NET.Sdk">
          <PropertyGroup>
            <Version>6.7.8</Version>
          </PropertyGroup>
        </Project>'''
        
        with patch('xml.etree.ElementTree.parse') as mock_parse:
            root = ET.fromstring(xml_content)
            mock_parse.return_value.getroot.return_value = root
            version = get_current_version(ProjectVersionTypes.DOTNET_CSPROJ)
            assert version == "6.7.8"

    @patch('vupdate.find_project_file')
    def test_dotnet_fsproj(self, mock_find):
        mock_find.return_value = "test.fsproj"
        xml_content = '''<?xml version="1.0" encoding="utf-8"?>
        <Project Sdk="Microsoft.NET.Sdk">
          <PropertyGroup>
            <Version>7.8.9</Version>
          </PropertyGroup>
        </Project>'''
        
        with patch('xml.etree.ElementTree.parse') as mock_parse:
            root = ET.fromstring(xml_content)
            mock_parse.return_value.getroot.return_value = root
            version = get_current_version(ProjectVersionTypes.DOTNET_FSPROJ)
            assert version == "7.8.9"

    @patch('vupdate.find_project_file')
    def test_dotnet_no_version(self, mock_find):
        mock_find.return_value = "test.csproj"
        xml_content = '''<?xml version="1.0" encoding="utf-8"?>
        <Project Sdk="Microsoft.NET.Sdk">
          <PropertyGroup>
          </PropertyGroup>
        </Project>'''
        
        with patch('xml.etree.ElementTree.parse') as mock_parse:
            root = ET.fromstring(xml_content)
            mock_parse.return_value.getroot.return_value = root
            with pytest.raises(Exception, match="No version found"):
                get_current_version(ProjectVersionTypes.DOTNET_CSPROJ)


class TestHelperFunctions:
    @patch('os.path.isfile')
    def test_find_version_file_root(self, mock_isfile):
        mock_isfile.side_effect = lambda f: f == "VERSION"
        assert find_version_file() == "VERSION"

    @patch('os.path.isfile')
    @patch('os.path.join')
    def test_find_version_file_in_app(self, mock_join, mock_isfile):
        mock_join.side_effect = lambda *args: "/".join(args)
        mock_isfile.side_effect = lambda f: f == "app/VERSION"
        assert find_version_file() == "app/VERSION"

    @patch('os.path.isfile')
    @patch('os.path.isdir')
    @patch('os.listdir')
    @patch('os.path.join')
    def test_find_version_file_in_subdir(self, mock_join, mock_listdir, mock_isdir, mock_isfile):
        mock_join.side_effect = lambda *args: "/".join(args)
        mock_listdir.return_value = ["src", "docs"]
        mock_isdir.side_effect = lambda f: f in ["src", "docs"]
        mock_isfile.side_effect = lambda f: f == "src/VERSION"
        assert find_version_file() == "src/VERSION"

    @patch('os.listdir')
    @patch('os.path.isfile')
    def test_find_gemspec_file(self, mock_isfile, mock_listdir):
        mock_listdir.return_value = ["test.gemspec", "other.file"]
        mock_isfile.return_value = True
        assert find_gemspec_file() == "test.gemspec"

    @patch('os.listdir')
    @patch('os.path.isfile')
    def test_find_project_file(self, mock_isfile, mock_listdir):
        mock_listdir.return_value = ["test.csproj", "other.file"]
        mock_isfile.return_value = True
        assert find_project_file(".csproj") == "test.csproj"

    def test_get_version_file_prefix_with_v(self):
        with patch('builtins.open', mock_open(read_data="v1.0.0\n")):
            assert get_version_file_prefix("VERSION") == "v"

    def test_get_version_file_prefix_without_v(self):
        with patch('builtins.open', mock_open(read_data="1.0.0\n")):
            assert get_version_file_prefix("VERSION") == ""