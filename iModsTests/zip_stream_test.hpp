/*
zipstream Library License:
--------------------------

The zlib/libpng License Copyright (c) 2003 Jonathan de Halleux.

This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.

Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution

Author: Jonathan de Halleux, dehalleux@pelikhan.com, 2003
*/

namespace zlib_stream{

bool test_buffer_to_buffer();
bool test_wbuffer_to_wbuffer();
bool test_string_string();
bool test_wstring_wstring();
bool test_file_file(bool add_gzip_header);
bool test_crc();

};