{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "rmapi";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "juruen";
    repo = pname;
    rev = "v${version}";
    sha256 = "1z0b3bx9kb9dwq6r65qmw1ypfjlbkmpvk5knj05k910b38iwazpg";
  };

  modSha256 = "17qhi36j6xdwpgs4rmwljwixj5xq6qzpzlg9zy0ss8jv6d39y9gj";

  meta = with lib; {
    description = "Go app that allows you to access your reMarkable tablet files through the Cloud API";
    homepage = "https://github.com/juruen/rmapi";
    maintainers = with maintainers; [ jpas ];
    license = licenses.agpl3;
    platforms = platforms.unix;
  };
}
