#!/usr/bin/env -S v run

import net.http { Request }
import prantlf.jany { Any }
import prantlf.json { StringifyOpts, stringify }

fn main() {
	token := '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'
	url := 'https://api.github.com/repos/prantlf/v-strutil/releases'
	ver := '0.8.0'
	body := '## [0.8.0](https://github.com/prantlf/v-strutil/compare/v0.7.0...v0.8.0) (2023-09-10)

### Features

* Add functions cutting lines from start and end ([1c7227f](https://github.com/prantlf/v-strutil/commit/1c7227f76f3b13a874daef1a517b91bf7a1295c5))'
	data := '{"tag_name":"v${ver}","name":"${ver}","body":${stringify(Any(body), StringifyOpts{})}}'
	println(data)
	mut req := Request{
		method: .post
		url:    url
		data:   data
	}
	req.add_header(.accept, 'application/vnd.github+json')
	req.add_header(.authorization, 'Bearer ${token}')
	req.add_header(.content_type, 'application/json')
	req.add_custom_header('X-GitHub-Api-Version', '2022-11-28')!
	res := req.do()!
	if res.status_code != 201 {
		panic(error('${res.status_code}: ${res.status_msg}'))
	}
	println(res.body)
}
