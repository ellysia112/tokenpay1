class Boost1651 < Formula
  desc "Collection of portable C++ source libraries"
  homepage "https://www.boost.org/"
  url "https://archives.boost.io/release/1.65.1/source/boost_1_65_1.tar.bz2"
  sha256 "9807a5d16566c57fd74fb522764e0b134a8bbe6b6e8967b83afefd30dcd3be81"
  revision 1
  
  keg_only :versioned_formula

  depends_on "icu4c@76"

  option "with-icu4c", "Build regexp engine with icu support"
  option "without-single", "Disable building single-threading variant"
  option "without-static", "Disable building static library variant"

  deprecated_option "with-icu" => "with-icu4c"

  depends_on "icu4c" => :optional

   def install
    # Force boost to compile with the desired compiler
    open("user-config.jam", "a") do |file|
      if OS.mac?
        file.write "using darwin : : #{ENV.cxx} ;\n"
      else
        file.write "using gcc : : #{ENV.cxx} ;\n"
      end
    end

    # libdir should be set by --prefix but isn't
    icu4c_prefix = Formula["icu4c@76"].opt_prefix
    bootstrap_args = %W[
      --prefix=#{prefix}
      --libdir=#{lib}
      --with-icu=#{icu4c_prefix}
    ]

    # Handle libraries that will not be built.
    without_libraries = ["python", "mpi"]

    # Boost.Log cannot be built using Apple GCC at the moment. Disabled
    # on such systems.
    without_libraries << "log" if ENV.compiler == :gcc

    bootstrap_args << "--without-libraries=#{without_libraries.join(",")}"

    # layout should be synchronized with boost-python and boost-mpi
    args = %W[
      --prefix=#{prefix}
      --libdir=#{lib}
      -d2
      -j#{ENV.make_jobs}
      --layout=tagged-1.66
      --user-config=user-config.jam
      -sNO_LZMA=1
      -sNO_ZSTD=1
      install
      threading=multi,single
      link=shared,static
    ]

    # Boost is using "clang++ -x c" to select C compiler which breaks C++14
    # handling using ENV.cxx14. Using "cxxflags" and "linkflags" still works.
    args << "cxxflags=-std=c++14"
    args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++" if ENV.compiler == :clang

    system "./bootstrap.sh", *bootstrap_args
    system "./b2", "headers"
    system "./b2", *args
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <boost/algorithm/string.hpp>
      #include <string>
      #include <vector>
      #include <assert.h>
      using namespace boost::algorithm;
      using namespace std;

      int main()
      {
        string str("a,b");
        vector<string> strVec;
        split(strVec, str, is_any_of(","));
        assert(strVec.size()==2);
        assert(strVec[0]=="a");
        assert(strVec[1]=="b");
        return 0;
      }
    CPP
    system ENV.cxx, "-I#{Formula["boost@1.76"].opt_include}", "test.cpp", "-std=c++14", "-o", "test"
    system "./test"
  end
end