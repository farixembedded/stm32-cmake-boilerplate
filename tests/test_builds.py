# Copyright (c) 2021, Fractal Embedded LLC
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import pytest
import subprocess
import shutil
from pathlib import Path
import os
import hashlib


CI_BUILD_FOLDER=Path("ci-build/")


def md5(path: Path):
    hash_md5 = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


class Builder:
    def __init__(self, project_path, elf_name=None, elf_md5=None):
        self.name = self.__class__.__name__
        self.project_path = Path(project_path)
        self.build_path = CI_BUILD_FOLDER / project_path
        self.elf_path = self.build_path / elf_name
        self.elf_md5 = elf_md5

        try:
            shutil.rmtree(self.build_path)
        except FileNotFoundError:
            pass

        toolchain_define = ''
        if 'STM32_TOOLCHAIN_PATH' in os.environ:
            toolchain_define = f"-DSTM32_TOOLCHAIN_PATH={os.environ['STM32_TOOLCHAIN_PATH']}"

        subprocess.check_call(f"cmake -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON {self.project_path} -B {self.build_path} {toolchain_define}", shell=True)
        subprocess.check_call(f"cmake --build {self.build_path}", shell=True)

        subprocess.check_call(f"cat {self.build_path}/output.map")


@pytest.fixture(params=[
    ("Examples/simple-example", 'simple-example.elf', '535c56b0d3e47a3c4d954478c567dfc6'),
    # ("Examples/cubemx-example", 'cubemx-example.elf', 'c240fc7f76682049a2e0e823dd9c3af2'),
    # ("Examples/blinky-example", "blinky-example.elf", "0188f3a1b30e979c37c94c8f4414ee69"),
    ],
    ids=lambda x: x[0],
    scope='module')
def build(request):
    return Builder(*request.param)


class TestBuild:
    def test_output_is_elf(self, build: Builder):
        output = subprocess.check_output(f"file {build.elf_path}", shell=True).decode()
        assert "ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV)" in output

    def test_output_is_binary_reproduceable(self, build: Builder):
        assert md5(build.elf_path) == build.elf_md5
