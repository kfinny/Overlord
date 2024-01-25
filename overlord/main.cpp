#include "main.h"

using namespace std;

int main()
{
	cout << "Hello Overlord." << endl;
	cout << "I am using libtsk version " << tsk_version_get_str() << endl;
	cout << "I am using zlib version " << ZLIB_VERSION << endl;
	cout << "I am using openssl version " << SSLeay_version(SSLEAY_VERSION) << endl;
	cout << "I am using yara version " << YR_VERSION << endl;
	cout << "I am using httplib version  " << CPPHTTPLIB_VERSION << endl;

	httplib::Client cli("https://www.google.com");

	auto response = cli.Get("/");
	if (response->status == httplib::StatusCode::OK_200) {
		cout << "Successful connection to Google using HTTPS" << endl;
	}
	else {
		cout << "Received bad response " << response->status << endl;
	}
	return 0;
}
