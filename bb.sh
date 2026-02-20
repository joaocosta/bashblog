#!/usr/bin/env bash
set -euo pipefail

# BashBlog, a simple blog system written in a single bash script
# (C) Carlos Fenollosa <carlos.fenollosa@gmail.com>, 2011-2016 and contributors
# https://github.com/carlesfe/bashblog/contributors
# Check out README.md for more details

# Global variables
TMP_FILES=()

#######################################
# Clean up temporary files on exit.
# Arguments:
#   None
#######################################
cleanup() {
    local f
    if [[ ${#TMP_FILES[@]} -gt 0 ]]; then
        for f in "${TMP_FILES[@]}"; do
            if [[ -n "${f:-}" && -f "${f:-}" ]]; then
                rm -f "$f"
            fi
        done
    fi
    return 0
}
trap cleanup EXIT

#######################################
# Create a temporary file and register it for cleanup.
# Arguments:
#   Optional suffix for the filename.
# Outputs:
#   The path to the created temporary file.
#######################################
mktmp() {
    local suffix="${1:-}"
    local tmp
    if [[ -n "$suffix" ]]; then
        tmp=$(mktemp ".bb.tmp.XXXXXX.$suffix")
    else
        tmp=$(mktemp ".bb.tmp.XXXXXX")
    fi
    TMP_FILES+=("$tmp")
    printf '%s\n' "$tmp"
}

# Config file. Any settings "key=value" written there will override the
# global_variables defaults. Useful to avoid editing bb.sh and having to deal
# with merges in VCS
GLOBAL_CONFIG=".config"

#######################################
# Load default configuration variables.
# Arguments:
#   None
#######################################
global_variables() {
    global_software_name="BashBlog"
    global_software_version="2.10"

    # Blog title
    global_title="My fancy blog"
    # The typical subtitle for each blog
    global_description="A blog about turtles and carrots"
    # The public base URL for this blog
    global_url="http://example.com/blog"

    # Your name
    global_author="John Smith"
    # You can use twitter or facebook or anything for global_author_url
    global_author_url="http://twitter.com/example"
    # Your email
    global_email="john@smith.com"

    # CC by-nc-nd is a good starting point, you can change this to "&copy;" for Copyright
    global_license="CC by-nc-nd"

    # If you have a Google Analytics ID (UA-XXXXX) and wish to use the standard
    # embedding code, put it on global_analytics
    # If you have custom analytics code (i.e. non-google) or want to use the Universal
    # code, leave global_analytics empty and specify a global_analytics_file
    global_analytics=""
    global_analytics_file=""

    # Leave this empty (i.e. "") if you don't want to use feedburner,
    # or change it to your own URL
    global_feedburner=""

    # Change this to your username if you want to use twitter for comments
    global_twitter_username=""
    # Default image for the Twitter cards. Use an absolute URL
    global_twitter_card_image=""
    # Set this to false for a Twitter button with share count. The cookieless version
    # is just a link.
    global_twitter_cookieless="true"

    # Change this to your disqus username to use disqus for comments
    global_disqus_username=""

    # Blog generated files
    # index page of blog (it is usually good to use "index.html" here)
    index_file="index.html"
    number_of_index_articles="8"
    # global archive
    archive_index="all_posts.html"
    tags_index="all_tags.html"

    # Non blogpost files. Bashblog will ignore these. Useful for static pages and custom content
    # Add them as a bash array, e.g. non_blogpost_files=("news.html" "test.html")
    non_blogpost_files=()

    # feed file (rss in this case)
    blog_feed="feed.rss"
    number_of_feed_articles="10"
    # "cut" blog entry when putting it to index page. Leave blank for full articles in front page
    # i.e. include only up to first '<hr>', or '----' in markdown
    cut_do="cut"
    # When cutting, cut also tags? If "no", tags will appear in index page for cut articles
    cut_tags="yes"
    # Regexp matching the HTML line where to do the cut
    # note that slash is regexp separator so you need to prepend it with backslash
    cut_line='<hr ?\/?>'
    # save markdown file when posting with "bb post -m". Leave blank to discard it.
    save_markdown="yes"
    # prefix for tags/categories files
    # please make sure that no other html file starts with this prefix
    prefix_tags="tag_"
    # personalized header and footer (only if you know what you're doing)
    # DO NOT name them .header.html, .footer.html or they will be overwritten
    # leave blank to generate them, recommended
    header_file=""
    footer_file=""
    # extra content to add just after we open the <body> tag
    # and before the actual blog content
    body_begin_file=""
    # extra content to add just before we close </body>
    body_end_file=""
    # extra content to ONLY on the index page AFTER `body_begin_file` contents
    # and before the actual content
    body_begin_file_index=""
    # CSS files to include on every page, f.ex. css_include=('main.css' 'blog.css')
    # leave empty to use generated
    css_include=()
    # HTML files to exclude from index, f.ex. post_exclude=('imprint.html 'aboutme.html')
    html_exclude=()

    # Localization and i18n
    # "Comments?" (used in twitter link after every post)
    template_comments="Comments?"
    # "Read more..." (link under cut article on index page)
    template_read_more="Read more..."
    # "View more posts" (used on bottom of index page as link to archive)
    template_archive="View more posts"
    # "All posts" (title of archive page)
    template_archive_title="All posts"
    # "All tags"
    template_tags_title="All tags"
    # "posts" (on "All tags" page, text at the end of each tag line, like "2. Music - 15 posts")
    template_tags_posts="posts"
    template_tags_posts_2_4="posts"  # Some slavic languages use a different plural form for 2-4 items
    template_tags_posts_singular="post"
    # "Posts tagged" (text on a title of a page with index of one tag, like "My Blog - Posts tagged "Music"")
    template_tag_title="Posts tagged"
    # "Tags:" (beginning of line in HTML file with list of all tags for this article)
    template_tags_line_header="Tags:"
    # "Back to the index page" (used on archive page, it is link to blog index)
    template_archive_index_page="Back to the index page"
    # "Subscribe" (used on bottom of index page, it is link to RSS feed)
    template_subscribe="Subscribe"
    # "Subscribe to this page..." (used as text for browser feed button that is embedded to html)
    template_subscribe_browser_button="Subscribe to this page..."
    # "Tweet" (used as twitter text button for posting to twitter)
    template_twitter_button="Tweet"
    template_twitter_comment="&lt;Type your comment here but please leave the URL so that other people can follow the comments&gt;"

    # The locale to use for the dates displayed on screen
    date_format="%B %d, %Y"
    date_locale="C"
    date_inpost="bashblog_timestamp"
    # Don't change these dates
    date_format_full="%a, %d %b %Y %H:%M:%S %z"
    date_format_timestamp="%Y%m%d%H%M.%S"
    date_allposts_header="%B %Y"

    # Perform the post title -> filename conversion
    # Experts only. You may need to tune the locales too
    # Leave empty for no conversion, which is not recommended
    # This default filter respects backwards compatibility
    convert_filename="iconv -f utf-8 -t ascii//translit | sed 's/^-*//' | tr [:upper:] [:lower:] | tr ' ' '-' | tr -dc '[:alnum:]-'"

    # URL where you can view the post while it's being edited
    # same as global_url by default
    # You can change it to path on your computer, if you write posts locally
    # before copying them to the server
    preview_url=""

    # Markdown location. Trying to autodetect by default.
    # The invocation must support the signature 'markdown_bin in.md > out.html'
    [[ -f Markdown.pl ]] && markdown_bin=./Markdown.pl || markdown_bin=$(which Markdown.pl 2>/dev/null || which markdown 2>/dev/null)
}

#######################################
# Check for the validity of some variables.
# Arguments:
#   None
#######################################
global_variables_check() {
    if [[ "${header_file:-}" == ".header.html" ]]; then
        printf 'Please check your configuration. '"'.header.html' is not a valid value for the setting 'header_file'\n"
        exit 1
    fi
    if [[ "${footer_file:-}" == ".footer.html" ]]; then
        printf 'Please check your configuration. '"'.footer.html' is not a valid value for the setting 'footer_file'\n"
        exit 1
    fi
}

#######################################
# Test if the markdown script is working correctly.
# Arguments:
#   None
# Returns:
#   0 if working, non-zero otherwise.
#######################################
test_markdown() {
    [[ -n "${markdown_bin:-}" ]] && {
        [[ "$("$markdown_bin" <<< $'line 1\n\nline 2')" == $'<p>line 1</p>\n\n<p>line 2</p>' ]] ||
        [[ "$("$markdown_bin" <<< $'line 1\n\nline 2')" == $'<p>line 1</p>\n<p>line 2</p>' ]]
    }
}

#######################################
# Parse a Markdown file into HTML and return the generated file.
# Arguments:
#   $1: Path to the Markdown file.
# Outputs:
#   Path to the generated HTML file.
#######################################
markdown() {
    local input_file="$1"
    local out
    out=$(mktmp "html")
    "$markdown_bin" "$input_file" > "$out"
    printf '%s\n' "$out"
}

#######################################
# Prints the required google analytics code.
# Arguments:
#   None
#######################################
google_analytics() {
    if [[ -z "${global_analytics:-}" && -z "${global_analytics_file:-}" ]]; then
        return 0
    fi

    if [[ -z "${global_analytics_file:-}" ]]; then
        cat <<EOF
<script type="text/javascript">

var _gaq = _gaq || [];
_gaq.push(['_setAccount', '${global_analytics}']);
_gaq.push(['_trackPageview']);

(function() {
var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();

</script>
EOF
    else
        cat "$global_analytics_file"
    fi
}

#######################################
# Prints the required code for disqus comments.
# Arguments:
#   None
#######################################
disqus_body() {
    if [[ -z "${global_disqus_username:-}" ]]; then
        return 0
    fi

    cat <<EOF
<div id="disqus_thread"></div>
            <script type="text/javascript">
            /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
               var disqus_shortname = '${global_disqus_username}'; // required: replace example with your forum shortname

            /* * * DONT EDIT BELOW THIS LINE * * */
            (function() {
            var dsq = document.createElement("script"); dsq.type = "text/javascript"; dsq.async = true;
            dsq.src = "//" + disqus_shortname + ".disqus.com/embed.js";
            (document.getElementsByTagName("head")[0] || document.getElementsByTagName("body")[0]).appendChild(dsq);
            })();
            </script>
            <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
            <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
EOF
}

#######################################
# Prints the required code for disqus in the footer.
# Arguments:
#   None
#######################################
disqus_footer() {
    if [[ -z "${global_disqus_username:-}" ]]; then
        return 0
    fi
    cat <<EOF
<script type="text/javascript">
        /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
        var disqus_shortname = '${global_disqus_username}'; // required: replace example with your forum shortname

        /* * * DONT EDIT BELOW THIS LINE * * */
        (function () {
        var s = document.createElement("script"); s.async = true;
        s.type = "text/javascript";
        s.src = "//" + disqus_shortname + ".disqus.com/count.js";
        (document.getElementsByTagName("HEAD")[0] || document.getElementsByTagName("BODY")[0]).appendChild(s);
    }());
    </script>
EOF
}

#######################################
# Reads HTML file from stdin, prints its content to stdout.
# Arguments:
#   $1: where to start ("text" or "entry")
#   $2: where to stop ("text" or "entry")
#   $3: "cut" to remove text from <hr /> to <!-- text end -->
#######################################
get_html_file_content() {
    local start="$1"
    local stop="$2"
    local cut="${3:-}"
    awk "/<!-- $start begin -->/, /<!-- $stop end -->/{
        if (!/<!-- $start begin -->/ && !/<!-- $stop end -->/) print
        if (\"$cut\" == \"cut\" && /$cut_line/){
            if (\"$stop\" == \"text\") exit # no need to read further
            while (getline > 0 && !/<!-- text end -->/) {
                if (\"$cut_tags\" == \"no\" && /^<p>$template_tags_line_header/ ) print
            }
        }
    }"
}

#######################################
# Edit an existing, published .html file while keeping its original timestamp.
# Arguments:
#   $1: The file to edit.
#   $2: (optional) Edit mode ("keep" or "full").
#######################################
edit() {
    local file_to_edit="$1"
    local mode="${2:-}"

    if [[ ! -f "${file_to_edit%%.*}.html" ]]; then
        printf 'Can'"'t edit post \"%s\", did you mean to use \"bb.sh post <draft_file>\"?\n" "${file_to_edit%%.*}.html"
        exit 1
    fi

    # Original post timestamp
    local edit_timestamp
    local touch_timestamp
    edit_timestamp=$(LC_ALL=C date -r "${file_to_edit%%.*}.html" +"$date_format_full" )
    touch_timestamp=$(LC_ALL=C date -r "${file_to_edit%%.*}.html" +"$date_format_timestamp")

    local tags_before
    tags_before=$(tags_in_post "${file_to_edit%%.*}.html")

    local filename
    local TMPFILE
    if [[ "$mode" == "full" ]]; then
        "$EDITOR" "$file_to_edit"
        filename="$file_to_edit"
    else
        if [[ "${file_to_edit##*.}" == "md" ]]; then
            if ! test_markdown; then
                printf "Markdown is not working, please edit HTML file directly.\n"
                exit 1
            fi
            # editing markdown file
            "$EDITOR" "$file_to_edit"
            TMPFILE=$(markdown "$file_to_edit")
            filename="${file_to_edit%%.*}.html"
        else
            # Create the content file
            TMPFILE=$(mktmp "html")
            # Title
            get_post_title "$file_to_edit" > "$TMPFILE"
            # Post text with plaintext tags
            get_html_file_content 'text' 'text' <"$file_to_edit" | sed "/^<p>$template_tags_line_header/s|<a href='$prefix_tags\([^']*\).html'>\\1</a>|\\1|g" >> "$TMPFILE"
            "$EDITOR" "$TMPFILE"
            filename="$file_to_edit"
        fi
        rm -f "$filename"
        if [[ "$mode" == "keep" ]]; then
            filename=$(parse_file "$TMPFILE" "$edit_timestamp" "$filename")
        else
            filename=$(parse_file "$TMPFILE" "$edit_timestamp") # this command sets $filename as the html processed file
            if [[ "${file_to_edit##*.}" == "md" ]]; then
                mv "$file_to_edit" "${filename%%.*}.md" 2>/dev/null || true
            fi
        fi
        rm -f "${TMPFILE:-}"
    fi
    touch -t "$touch_timestamp" "$filename"
    touch -t "$touch_timestamp" "$file_to_edit"
    chmod 644 "$filename"
    printf "Posted %s\n" "$filename"

    local tags_after
    local relevant_tags
    tags_after=$(tags_in_post "$filename")
    relevant_tags=$(printf '%s %s' "$tags_before" "$tags_after" | tr ',' ' ' | tr ' ' '\n' | sort -u | tr '\n' ' ')
    if [[ -n "${relevant_tags:-}" ]]; then
        local relevant_posts
        # shellcheck disable=SC2086
        relevant_posts="$(posts_with_tags $relevant_tags) $filename"
        rebuild_tags "$relevant_posts" "$relevant_tags"
    fi
}

#######################################
# Create a Twitter summary (twitter "card") for the post.
# Arguments:
#   $1: The post file.
#   $2: The title.
#######################################
twitter_card() {
    local post_file="$1"
    local title="$2"

    if [[ -z "${global_twitter_username:-}" ]]; then
        return 0
    fi

    printf "<meta name='twitter:card' content='summary' />\n"
    printf "<meta name='twitter:site' content='@%s' />\n" "$global_twitter_username"
    printf "<meta name='twitter:title' content='%s' />\n" "$title" # Twitter truncates at 70 char

    local description
    description=$(grep -v "^<p>$template_tags_line_header" "$post_file" | sed -e 's/<[^>]*>//g' | tr '\n' ' ' | sed "s/\"/'/g" | head -c 250)
    printf "<meta name='twitter:description' content=\"%s\" />\n" "$description"

    # For the image we try to locate the first image in the article
    local image
    image=$(sed -n '2,$ d; s/.*<img.*src="\([^"]*\)".*/\1/p' "$post_file")

    # If none, then we try a global setting image
    if [[ -z "${image:-}" && -n "${global_twitter_card_image:-}" ]]; then
        image="$global_twitter_card_image"
    fi

    # If none, return
    if [[ -z "${image:-}" ]]; then
        return 0
    fi

    # Final housekeeping
    if [[ ! "$image" =~ ^https?:// ]]; then
        image="$global_url/$image" # Check that URL is absolute
    fi
    printf "<meta name='twitter:image' content='%s' />\n" "$image"
}

#######################################
# Adds the code needed by the twitter button.
# Arguments:
#   $1: The post URL.
#######################################
twitter() {
    local post_url="$1"

    if [[ -z "${global_twitter_username:-}" ]]; then
        return 0
    fi

    if [[ -z "${global_disqus_username:-}" ]]; then
        if [[ "${global_twitter_cookieless:-}" == "true" ]]; then
            local id=$RANDOM
            local search_engine="https://twitter.com/search?q="

            printf "<p id='twitter'><a href='http://twitter.com/intent/tweet?url=%s&text=%s&via=%s'>%s %s</a> " \
                "$post_url" "$template_twitter_comment" "$global_twitter_username" "$template_comments" "$template_twitter_button"
            printf "<a href='%s%s'><span id='count-%s'></span></a>&nbsp;</p>\n" "$search_engine" "$post_url" "$id"
            return 0
        else
            printf "<p id='twitter'>%s&nbsp;" "$template_comments"
        fi
    else
        printf "<p id='twitter'><a href=\"%s#disqus_thread\">%s</a> &nbsp;" "$post_url" "$template_comments"
    fi

    printf "<a href=\"https://twitter.com/share\" class=\"twitter-share-button\" data-text=\"%s\" data-url=\"%s\"" \
        "$template_twitter_comment" "$post_url"
    printf " data-via=\"%s\"" "$global_twitter_username"
    printf ">%s</a>	<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=\"//platform.twitter.com/widgets.js\";fjs.parentNode.insertBefore(js,fjs);}}(document,\"script\",\"twitter-wjs\");</script>" \
        "$template_twitter_button"
    printf "</p>\n"
}

#######################################
# Check if the file is a 'boilerplate' (i.e. not a post).
# Arguments:
#   $1: The file.
# Returns:
#   0 if boilerplate, 1 otherwise.
#######################################
is_boilerplate_file() {
    local file_path="$1"
    local name="${file_path#./}"
    local item

    # First check against user-defined non-blogpost pages
    for item in "${non_blogpost_files[@]:-}"; do
        if [[ "$name" == "$item" ]]; then
            return 0
        fi
    done

    case "$name" in
        "$index_file" | "$archive_index" | "$tags_index" | "${footer_file:-}" | "${header_file:-}" | "${global_analytics_file:-}" | "$prefix_tags"*)
            return 0
            ;;
        *) # Check for excluded
            local excl
            for excl in "${html_exclude[@]:-}"; do
                if [[ "$name" == "$excl" ]]; then
                    return 0
                fi
            done
            return 1
            ;;
    esac
}

#######################################
# Adds all the bells and whistles to format the html page.
# Arguments:
#   $1: a file with the body of the content
#   $2: the output file
#   $3: "yes" if generating index.html, "no" otherwise
#   $4: title for the html header
#   $5: original blog timestamp
#   $6: post author
#######################################
# In this specific case, the script is only using the variable value (the string containing the filename) for a
# comparison. It never actually opens the file for reading (e.g., via cat, grep, or redirection) inside that block.
# shellcheck disable=SC2094
create_html_page() {
    local content="$1"
    local filename="$2"
    local index="$3"
    local title="$4"
    local timestamp="${5:-}"
    local author="${6:-}"

    # Create the actual blog post
    {
        cat ".header.html"
        printf "<title>%s</title>\n" "$title"
        google_analytics
        twitter_card "$content" "$title"
        printf "</head><body>\n"

        # stuff to add before the actual body content
        if [[ -n "${body_begin_file:-}" ]]; then
            cat "$body_begin_file"
        fi
        if [[ "$filename" == "$index_file"* && -n "${body_begin_file_index:-}" ]]; then
            cat "$body_begin_file_index"
        fi

        # body divs
        cat <<EOF
<div id="divbodyholder">
<div class="headerholder"><div class="header">
<div id="title">
EOF
        cat .title.html
        printf '</div></div></div>\n'
        printf '<div id="divbody"><div class="content">\n'

        local file_url="${filename#./}"
        file_url="${file_url%.rebuilt}" # Get the correct URL when rebuilding

        if [[ "$index" == "no" ]]; then
            printf '<!-- entry begin -->\n'
            printf "<h3><a class=\"ablack\" href=\"%s\">\n" "$file_url"
            # remove possible <p>'s on the title because of markdown conversion
            local clean_title="${title//<p>/}"
            clean_title="${clean_title//<\/p>/}"
            printf "%s\n" "$clean_title"
            printf '</a></h3>\n'

            if [[ -z "$timestamp" ]]; then
                printf "<!-- %s: #%s# -->\n" "$date_inpost" "$(LC_ALL="$date_locale" date +"$date_format_timestamp")"
            else
                printf "<!-- %s: #%s# -->\n" "$date_inpost" "$(LC_ALL="$date_locale" date +"$date_format_timestamp" --date="$timestamp")"
            fi

            if [[ -z "$timestamp" ]]; then
                printf "<div class=\"subtitle\">%s" "$(LC_ALL="$date_locale" date +"$date_format")"
            else
                printf "<div class=\"subtitle\">%s" "$(LC_ALL="$date_locale" date +"$date_format" --date="$timestamp")"
            fi

            if [[ -n "$author" ]]; then
                printf " &mdash; \n%s" "$author"
            fi
            printf "</div>\n"
            printf '<!-- text begin -->\n'
        fi

        cat "$content"

        if [[ "$index" == "no" ]]; then
            printf '\n<!-- text end -->\n'
            twitter "$global_url/$file_url"
            printf '<!-- entry end -->\n'
        fi

        printf '</div>\n'

        # Add disqus commments except for index and all_posts pages
        if [[ "$index" == "no" ]]; then
            disqus_body
        fi

        cat .footer.html
        printf '</div></div>\n'
        disqus_footer
        if [[ -n "${body_end_file:-}" ]]; then
            cat "$body_end_file"
        fi
        printf '</body></html>\n'
    } > "$filename"
}

#######################################
# Parse the plain text file into an html file.
# Arguments:
#   $1: source file name
#   $2: (optional) timestamp for the file
#   $3: (optional) destination file name
#######################################
parse_file() {
    local source_file="$1"
    local timestamp="${2:-}"
    local dest_filename="${3:-}"

    local title=""
    local filename=""
    local content=""
    local line

    while IFS='' read -r line; do
        if [[ -z "${title:-}" ]]; then
            # remove extra <p> and </p> added by markdown
            title=$(printf '%s' "$line" | sed 's/<\/*p>//g')
            if [[ -n "$dest_filename" ]]; then
                filename="$dest_filename"
            else
                filename="$title"
                if [[ -n "${convert_filename:-}" ]]; then
                    # shellcheck disable=SC2086
                    filename=$(printf '%s' "$title" | eval "$convert_filename")
                fi
                if [[ -z "${filename:-}" ]]; then
                    filename="$RANDOM"
                fi

                filename="${filename}.html"

                while [[ -f "$filename" ]]; do
                    filename="${filename%.html}$RANDOM.html"
                done
            fi
            content="${filename}.tmp"
        elif [[ "$line" == "<p>$template_tags_line_header"* ]]; then
            local tags
            tags=$(printf '%s' "$line" | cut -d ":" -f 2- | sed -e 's/<\/p>//g' -e 's/^ *//' -e 's/ *$//' -e 's/, /,/g')
            local array
            IFS=, read -r -a array <<< "$tags"

            printf "<p>%s " "$template_tags_line_header" >> "$content"
            local item
            for item in "${array[@]}"; do
                printf "<a href='%s%s.html'>%s</a>, " "$prefix_tags" "$item" "$item"
            done | sed 's/, $/<\/p>/g' >> "$content"
        else
            printf '%s\n' "$line" >> "$content"
        fi
    done < "$source_file"

    create_html_page "$content" "$filename" no "$title" "$timestamp" "$global_author"
    rm -f "$content"
    printf '%s\n' "$filename"
}

#######################################
# Manages the creation of the text file and parsing to HTML.
# Arguments:
#   $1: Command ("post").
#   $2: (optional) "-html" or draft filename.
#   $3: (optional) draft filename if $2 was "-html".
#######################################
write_entry() {
    local fmt
    if test_markdown; then
        fmt="md"
    else
        fmt="html"
    fi

    local f="${2:-}"
    if [[ "${2:-}" == "-html" ]]; then
        fmt="html"
        f="${3:-}"
    fi

    local TMPFILE
    if [[ -n "$f" ]]; then
        TMPFILE="$f"
        if [[ ! -f "$TMPFILE" ]]; then
            printf "The file doesn't exist\n"
            delete_includes
            exit 1
        fi
        local extension="${TMPFILE##*.}"
        [[ "$extension" == "md" || "$extension" == "html" ]] && fmt="$extension"
        [[ "${2:-}" == "-html" ]] && fmt="html"

        if [[ "$extension" == "md" ]]; then
            if ! test_markdown; then
                printf "Markdown is not working, please edit HTML file directly.\n"
                exit 1
            fi
        fi
    else
        TMPFILE=$(mktmp "$fmt")
        printf "Title on this line\n\n" >> "$TMPFILE"

        if [[ "$fmt" == "html" ]]; then
            cat <<EOF >> "$TMPFILE"
<p>The rest of the text file is an <b>html</b> blog post. The process will continue as soon
as you exit your editor.</p>

<p>$template_tags_line_header keep-this-tag-format, tags-are-optional, example</p>
EOF
        elif [[ "$fmt" == "md" ]]; then
            cat <<EOF >> "$TMPFILE"
The rest of the text file is a **Markdown** blog post. The process will continue
as soon as you exit your editor.

$template_tags_line_header keep-this-tag-format, tags-are-optional, beware-with-underscores-in-markdown, example
EOF
        fi
    fi
    chmod 600 "$TMPFILE"

    local post_status="E"
    local filename=""
    while [[ "$post_status" != "p" && "$post_status" != "P" ]]; do
        if [[ -n "${filename:-}" ]]; then
            rm -f "$filename"
        fi
        "$EDITOR" "$TMPFILE"
        if [[ "$fmt" == "md" ]]; then
            local html_from_md
            html_from_md=$(markdown "$TMPFILE")
            filename=$(parse_file "$html_from_md")
            rm -f "$html_from_md"
        else
            filename=$(parse_file "$TMPFILE")
        fi

        chmod 644 "$filename"
        local p_url="${preview_url:-$global_url}"
        printf "To preview the entry, open %s/%s in your browser\n" "$p_url" "$filename"

        printf "[P]ost this entry, [E]dit again, [D]raft for later? (p/E/d) "
        read -r post_status
        if [[ "$post_status" == "d" || "$post_status" == "D" ]]; then
            mkdir -p "drafts/"
            chmod 700 "drafts/"

            local title
            title=$(head -n 1 "$TMPFILE")
            if [[ -n "${convert_filename:-}" ]]; then
                # shellcheck disable=SC2086
                title=$(printf '%s' "$title" | eval "$convert_filename")
            fi
            [[ -z "${title:-}" ]] && title="$RANDOM"

            local draft="drafts/$title.$fmt"
            mv "$TMPFILE" "$draft"
            chmod 600 "$draft"
            rm -f "$filename"
            delete_includes
            printf "Saved your draft as '%s'\n" "$draft"
            exit 0
        fi
    done

    if [[ "$fmt" == "md" && -n "${save_markdown:-}" ]]; then
        mv "$TMPFILE" "${filename%%.*}.md"
    else
        rm -f "$TMPFILE"
    fi
    chmod 644 "$filename"
    printf "Posted %s\n" "$filename"

    local relevant_tags
    relevant_tags=$(tags_in_post "$filename")
    if [[ -n "${relevant_tags:-}" ]]; then
        local relevant_posts
        # shellcheck disable=SC2086
        relevant_posts="$(posts_with_tags $relevant_tags) $filename"
        rebuild_tags "$relevant_posts" "$relevant_tags"
    fi
}

#######################################
# Create an index page with all the posts.
# Arguments:
#   None
#######################################
all_posts() {
    printf "Creating an index page with all the posts "
    local contentfile
    contentfile=$(mktmp)

    {
        printf "<h3>%s</h3>\n" "$template_archive_title"
        local prev_month=""
        local i
        while IFS='' read -r i; do
            is_boilerplate_file "$i" && continue
            printf "." 1>&3
            local month
            month=$(LC_ALL="$date_locale" date -r "$i" +"$date_allposts_header")
            if [[ "$month" != "$prev_month" ]]; then
                [[ -n "$prev_month" ]] && printf "</ul>\n"
                printf "<h4 class='allposts_header'>%s</h4>\n" "$month"
                printf "<ul>\n"
                prev_month="$month"
            fi
            local title
            title=$(get_post_title "$i")
            printf "<li><a href=\"%s\">%s</a> &mdash;" "$i" "$title"
            local p_date
            p_date=$(LC_ALL="$date_locale" date -r "$i" +"$date_format")
            printf " %s</li>\n" "$p_date"
        done < <(ls -t ./*.html)
        printf "\n" 1>&3
        printf "</ul>\n"
        printf "<div id=\"all_posts\"><a href=\"./%s\">%s</a></div>\n" "$index_file" "$template_archive_index_page"
    } 3>&1 >"$contentfile"

    create_html_page "$contentfile" "${archive_index}.tmp" yes "$global_title &mdash; $template_archive_title" "" "$global_author"
    mv "${archive_index}.tmp" "$archive_index"
    chmod 644 "$archive_index"
    rm -f "$contentfile"
}

#######################################
# Create an index page with all the tags.
# Arguments:
#   None
#######################################
all_tags() {
    printf "Creating an index page with all the tags "
    local contentfile
    contentfile=$(mktmp)

    {
        printf "<h3>%s</h3>\n" "$template_tags_title"
        printf "<ul>\n"
        local i
        for i in "$prefix_tags"*.html; do
            [[ -f "$i" ]] || break
            printf "." 1>&3
            local nposts
            nposts=$(grep -c "<\!-- text begin -->" "$i")
            local tagname="${i#"$prefix_tags"}"
            tagname="${tagname%.html}"
            local word
            case "$nposts" in
                1) word="$template_tags_posts_singular" ;;
                2|3|4) word="$template_tags_posts_2_4" ;;
                *) word="$template_tags_posts" ;;
            esac
            printf "<li><a href=\"%s\">%s</a> &mdash; %s %s</li>\n" "$i" "$tagname" "$nposts" "$word"
        done
        printf "\n" 1>&3
        printf "</ul>\n"
        printf "<div id=\"all_posts\"><a href=\"./%s\">%s</a></div>\n" "$index_file" "$template_archive_index_page"
    } 3>&1 > "$contentfile"

    create_html_page "$contentfile" "${tags_index}.tmp" yes "$global_title &mdash; $template_tags_title" "" "$global_author"
    mv "${tags_index}.tmp" "$tags_index"
    chmod 644 "$tags_index"
    rm -f "$contentfile"
}

#######################################
# Generate the index.html with the content of the latest posts.
# Arguments:
#   None
#######################################
rebuild_index() {
    printf "Rebuilding the index "
    local newindexfile
    newindexfile=$(mktmp)
    local contentfile
    contentfile=$(mktmp "content")

    {
        local n=0
        local i
        while IFS='' read -r i; do
            is_boilerplate_file "$i" && continue
            ((n >= number_of_index_articles)) && break
            if [[ -n "${cut_do:-}" ]]; then
                get_html_file_content 'entry' 'entry' 'cut' <"$i" | awk "/$cut_line/ { print \"<p class=\\\"readmore\\\"><a href=\\\"$i\\\">$template_read_more</a></p>\" ; next } 1"
            else
                get_html_file_content 'entry' 'entry' <"$i"
            fi
            printf "." 1>&3
            n=$(( n + 1 ))
        done < <(ls -t ./*.html)

        local feed="${global_feedburner:-$blog_feed}"
        printf "<div id=\"all_posts\"><a href=\"%s\">%s</a> &mdash; <a href=\"%s\">%s</a> &mdash; <a href=\"%s\">%s</a></div>\n" \
            "$archive_index" "$template_archive" "$tags_index" "$template_tags_title" "$feed" "$template_subscribe"
    } 3>&1 >"$contentfile"

    printf "\n"

    create_html_page "$contentfile" "$newindexfile" yes "$global_title" "" "$global_author"
    rm -f "$contentfile"
    mv "$newindexfile" "$index_file"
    chmod 644 "$index_file"
}

#######################################
# Finds all tags referenced in one post.
# Arguments:
#   $1: Path to the HTML file.
# Outputs:
#   Space-separated list of tags.
#######################################
tags_in_post() {
    local post_file="$1"
    sed -n "/^<p>$template_tags_line_header/{s/^<p>$template_tags_line_header//;s/<[^>]*>//g;s/[ ,]\+/ /g;p;}" "$post_file" | tr ', ' ' '
}

#######################################
# Finds all posts referenced in a number of tags.
# Arguments:
#   Tags as multiple arguments.
# Outputs:
#   Space-separated list of post filenames.
#######################################
posts_with_tags() {
    if (($# < 1)); then
        return 0
    fi
    local existing_files=()
    local tag
    for tag in "$@"; do
        if [[ -f "$prefix_tags$tag.html" ]]; then
            existing_files+=("$prefix_tags$tag.html")
        fi
    done
    if [[ ${#existing_files[@]} -gt 0 ]]; then
        sed -n '/^<h3><a class="ablack" href="[^"]*">/{s/.*href="\([^"]*\)">.*/\1/;p;}' "${existing_files[@]}" 2> /dev/null
    fi
    return 0
}

#######################################
# Rebuilds tag_*.html files.
# Arguments:
#   $1: (optional) List of files.
#   $2: (optional) List of tags.
#######################################
rebuild_tags() {
    local files=""
    local tags=""
    local all_tags=""
    local n=0
    local tmpfile=""
    local tagname=""

    if (($# < 2)); then
        if ! ls ./*.html &> /dev/null; then
            return 0
        fi
        files=$(ls -t ./*.html)
        all_tags=yes
    else
        # shellcheck disable=SC2086
        files=$(printf '%s\n' $1 | sort -u)
        if [[ -n "${files:-}" ]]; then
            # shellcheck disable=SC2086
            files=$(ls -t $files)
        fi
        tags="$2"
    fi

    printf "Rebuilding tag pages "
    if [[ -n "${all_tags:-}" ]]; then
        rm -f ./"$prefix_tags"*.html &> /dev/null || true
    else
        local t
        for t in ${tags:-}; do
            rm -f "./$prefix_tags$t.html" &> /dev/null || true
        done
    fi

    tmpfile=$(mktmp)
    local i
    while IFS='' read -r i; do
        if [[ -z "${i:-}" ]]; then continue; fi
        is_boilerplate_file "$i" && continue
        printf "."
        if [[ -n "${cut_do:-}" ]]; then
            get_html_file_content 'entry' 'entry' 'cut' <"$i" | awk "/$cut_line/ { print \"<p class=\\\"readmore\\\"><a href=\\\"$i\\\">$template_read_more</a></p>\" ; next } 1"
        else
            get_html_file_content 'entry' 'entry' <"$i"
        fi >"$tmpfile"
        local tag
        for tag in $(tags_in_post "$i"); do
            if [[ -n "${all_tags:-}" || " ${tags:-} " == *" $tag "* ]]; then
                printf '%s' "$(cat "$tmpfile")" >> "$prefix_tags$tag.tmp.html"
            fi
        done
    done <<< "$files"
    rm -f "$tmpfile"

    if ls ./"$prefix_tags"*.tmp.html &> /dev/null; then
        while IFS='' read -r i; do
            tagname="${i#./"$prefix_tags"}"
            tagname="${tagname%.tmp.html}"
            create_html_page "$i" "$prefix_tags$tagname.html" yes "$global_title &mdash; $template_tag_title \"$tagname\"" "" "$global_author"
            rm -f "$i"
        done < <(ls -t ./"$prefix_tags"*.tmp.html 2>/dev/null)
    fi
    printf "\n"
}

#######################################
# Return the post title.
# Arguments:
#   $1: Path to the HTML file.
#######################################
get_post_title() {
    local html_file="$1"
    awk '/<h3><a class="ablack" href=".+">/, /<\/a><\/h3>/{if (!/<h3><a class="ablack" href=".+">/ && !/<\/a><\/h3>/) print}' "$html_file"
}

#######################################
# Return the post author.
# Arguments:
#   $1: Path to the HTML file.
#######################################
get_post_author() {
    local html_file="$1"
    awk '/<div class="subtitle">.+/, /<!-- text begin -->/{if (!/<div class="subtitle">.+/ && !/<!-- text begin -->/) print}' "$html_file" | sed 's/<\/div>//g'
}

#######################################
# Displays a list of the tags.
# Arguments:
#   $2: if "-n", tags will be sorted by number of posts.
#######################################
list_tags() {
    local do_sort=0
    if [[ "${2:-}" == "-n" ]]; then do_sort=1; fi

    if ! ls ./"$prefix_tags"*.html &> /dev/null; then
        printf "No posts yet. Use 'bb.sh post' to create one\n"
        return 0
    fi

    local lines=""
    local i
    for i in "$prefix_tags"*.html; do
        [[ -f "$i" ]] || break
        local nposts
        nposts=$(grep -c "<\!-- text begin -->" "$i")
        local tagname="${i#"$prefix_tags"}"
        tagname="${tagname%.html}"
        local word
        ((nposts > 1)) && word="$template_tags_posts" || word="$template_tags_posts_singular"
        lines+="$tagname # $nposts # $word\n"
    done

    if (( do_sort == 1 )); then
        printf "%b" "$lines" | column -t -s "#" | sort -nrk 2
    else
        printf "%b" "$lines" | column -t -s "#"
    fi
}

#######################################
# Displays a list of the posts.
# Arguments:
#   None
#######################################
list_posts() {
    if ! ls ./*.html &> /dev/null; then
        printf "No posts yet. Use 'bb.sh post' to create one\n"
        return 0
    fi

    local lines=""
    local n=1
    local i
    while IFS='' read -r i; do
        is_boilerplate_file "$i" && continue
        lines+="$n # $(get_post_title "$i") # $(LC_ALL="$date_locale" date -r "$i" +"$date_format")\n"
        n=$(( n + 1 ))
    done < <(ls -t ./*.html)

    printf "%b" "$lines" | column -t -s "#"
}

#######################################
# Generate the feed file.
# Arguments:
#   None
#######################################
make_rss() {
    printf "Making RSS "
    local rssfile
    rssfile=$(mktmp)

    {
        local pubdate
        pubdate=$(LC_ALL=C date +"$date_format_full")
        cat <<EOF
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/">
<channel><title>${global_title}</title><link>${global_url}/${index_file}</link>
<description>${global_description}</description><language>en</language>
<lastBuildDate>${pubdate}</lastBuildDate>
<pubDate>${pubdate}</pubDate>
<atom:link href="${global_url}/${blog_feed}" rel="self" type="application/rss+xml" />
EOF

        local n=0
        local i
        while IFS='' read -r i; do
            is_boilerplate_file "$i" && continue
            ((n >= number_of_feed_articles)) && break
            printf "." 1>&3
            printf '<item><title>'
            get_post_title "$i"
            printf '</title><description><![CDATA['
            get_html_file_content 'text' 'entry' "$cut_do" <"$i"
            cat <<EOF
]]></description><link>${global_url}/${i#./}</link>
<guid>${global_url}/$i</guid>
<dc:creator>$(get_post_author "$i")</dc:creator>
<pubDate>$(LC_ALL=C date -r "$i" +"$date_format_full")</pubDate></item>
EOF
            n=$(( n + 1 ))
        done < <(ls -t ./*.html)

        printf '</channel></rss>\n'
    } 3>&1 >"$rssfile"
    printf "\n"

    mv "$rssfile" "$blog_feed"
    chmod 644 "$blog_feed"
}

#######################################
# Generate headers, footers, etc.
# Arguments:
#   None
#######################################
create_includes() {
    {
        printf "<h1 class=\"nomargin\"><a class=\"ablack\" href=\"%s/%s\">%s</a></h1>\n" "$global_url" "$index_file" "$global_title"
        printf "<div id=\"description\">%s</div>\n" "$global_description"
    } > ".title.html"

    if [[ -f "${header_file:-}" ]]; then
        cp "$header_file" .header.html
    else
        {
            cat <<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"><head>
<meta http-equiv="Content-type" content="text/html;charset=UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
EOF
            local css
            for css in "${css_include[@]}"; do
                printf '<link rel="stylesheet" href="%s" type="text/css" />\n' "$css"
            done
            local feed="${global_feedburner:-$blog_feed}"
            printf "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"%s\" href=\"%s\" />\n" \
                "$template_subscribe_browser_button" "$feed"
        } > ".header.html"
    fi

    if [[ -f "${footer_file:-}" ]]; then
        cp "$footer_file" .footer.html
    else
        local protected_mail
        protected_mail="${global_email//@/&#64;}"
        protected_mail="${protected_mail//./&#46;}"
        cat <<EOF > ".footer.html"
<div id="footer">${global_license} <a href="${global_author_url}">${global_author}</a> &mdash; <a href="mailto:${protected_mail}">${protected_mail}</a><br/>
Generated with <a href="https://github.com/cfenollosa/bashblog">bashblog</a>, a single bash script to easily create blogs like this one</div>
EOF
    fi
}

#######################################
# Delete the temporarily generated include files.
# Arguments:
#   None
#######################################
delete_includes() {
    rm -f ".title.html" ".footer.html" ".header.html"
    return 0
}

#######################################
# Create the css file from scratch.
# Arguments:
#   None
#######################################
create_css() {
    if (( ${#css_include[@]} > 0 )); then
        return 0
    fi
    css_include=('main.css' 'blog.css')
    if [[ ! -f blog.css ]]; then
        cat <<EOF > blog.css
#title{font-size: x-large;}
a.ablack{color:black !important;}
li{margin-bottom:8px;}
ul,ol{margin-left:24px;margin-right:24px;}
#all_posts{margin-top:24px;text-align:center;}
.subtitle{font-size:small;margin:12px 0px;}
.content p{margin-left:24px;margin-right:24px;}
h1{margin-bottom:12px !important;}
#description{font-size:large;margin-bottom:12px;}
h3{margin-top:42px;margin-bottom:8px;}
h4{margin-left:24px;margin-right:24px;}
img{max-width:100%;}
#twitter{line-height:20px;vertical-align:top;text-align:right;font-style:italic;color:#333;margin-top:24px;font-size:14px;}
EOF
    fi

    if [[ -f ../style.css ]] && [[ ! -f main.css ]]; then
        ln -s "../style.css" "main.css"
    elif [[ ! -f main.css ]]; then
        cat <<EOF > main.css
body{font-family:Georgia,"Times New Roman",Times,serif;margin:0;padding:0;background-color:#F3F3F3;}
#divbodyholder{padding:5px;background-color:#DDD;width:100%;max-width:874px;margin:24px auto;}
#divbody{border:solid 1px #ccc;background-color:#fff;padding:0px 48px 24px 48px;top:0;}
.headerholder{background-color:#f9f9f9;border-top:solid 1px #ccc;border-left:solid 1px #ccc;border-right:solid 1px #ccc;}
.header{width:100%;max-width:800px;margin:0px auto;padding-top:24px;padding-bottom:8px;}
.content{margin-bottom:5%;}
.nomargin{margin:0;}
.description{margin-top:10px;border-top:solid 1px #666;padding:10px 0;}
h3{font-size:20pt;width:100%;font-weight:bold;margin-top:32px;margin-bottom:0;}
.clear{clear:both;}
#footer{padding-top:10px;border-top:solid 1px #666;color:#333333;text-align:center;font-size:small;font-family:"Courier New","Courier",monospace;}
a{text-decoration:none;color:#003366 !important;}
a:visited{text-decoration:none;color:#336699 !important;}
blockquote{background-color:#f9f9f9;border-left:solid 4px #e9e9e9;margin-left:12px;padding:12px 12px 12px 24px;}
blockquote img{margin:12px 0px;}
blockquote iframe{margin:12px 0px;}
EOF
    fi
    return 0
}

#######################################
# Regenerates all single post entries.
# Arguments:
#   None
#######################################
rebuild_all_entries() {
    printf "Rebuilding all entries "

    local i
    for i in ./*.html; do
        is_boilerplate_file "$i" && continue
        local contentfile
        contentfile=$(mktmp)

        printf "."
        local title
        title=$(get_post_title "$i")

        get_html_file_content 'text' 'text' <"$i" >> "$contentfile"

        local timestamp
        timestamp=$(awk '/<!-- '$date_inpost': .+ -->/ { print }' "$i" | cut -d '#' -f 2)
        if [[ -n "${timestamp:-}" ]]; then
            touch -t "$timestamp" "$i"
        fi
        timestamp=$(LC_ALL=C date -r "$i" +"$date_format_full")

        create_html_page "$contentfile" "$i.rebuilt" no "$title" "$timestamp" "$(get_post_author "$i")"
        timestamp=$(LC_ALL=C date -r "$i" +"$date_format_timestamp")
        mv "$i.rebuilt" "$i"
        chmod 644 "$i"
        touch -t "$timestamp" "$i"
        rm -f "$contentfile"
    done
    printf "\n"
    return 0
}

#######################################
# Displays the help.
# Arguments:
#   None
#######################################
usage() {
    printf "%s v%s\n" "$global_software_name" "$global_software_version"
    printf "Usage: %s command [filename]\n\n" "$0"
    printf "Commands:\n"
    printf "    post [-html] [filename] insert a new blog post, or the filename of a draft to continue editing it\n"
    printf "                            it tries to use markdown by default, and falls back to HTML if it's not available.\n"
    printf "                            use '-html' to override it and edit the post as HTML even when markdown is available\n"
    printf "    edit [-n|-f] [filename] edit an already published .html or .md file. **NEVER** edit manually a published .html file,\n"
    printf "                            always use this function as it keeps internal data and rebuilds the blog\n"
    printf "                            use '-n' to give the file a new name, if title was changed\n"
    printf "                            use '-f' to edit full html file, instead of just text part (also preserves name)\n"
    printf "    delete [filename]       deletes the post and rebuilds the blog\n"
    printf "    rebuild                 regenerates all the pages and posts, preserving the content of the entries\n"
    printf "    reset                   deletes everything except this script. Use with a lot of caution and back up first!\n"
    printf "    list                    list all posts\n"
    printf "    tags [-n]               list all tags in alphabetical order\n"
    printf "                            use '-n' to sort list by number of posts\n\n"
    printf "For more information please open %s in a code editor and read the header and comments\n" "$0"
}

#######################################
# Delete all generated content, leaving only this script.
# Arguments:
#   None
#######################################
reset() {
    printf 'Are you sure you want to delete all blog entries? Please write "Yes, I am!" \n'
    local line
    read -r line
    if [[ "$line" == "Yes, I am!" ]]; then
        rm -f .*.html ./*.html ./*.css ./*.rss &> /dev/null || true
        printf "\nDeleted all posts, stylesheets and feeds.\n"
        printf "Kept your old '.backup.tar.gz' just in case, please delete it manually if needed.\n"
    else
        printf "Phew! You dodged a bullet there. Nothing was modified.\n"
    fi
    return 0
}

#######################################
# Check that all required runtime dependencies are available.
#######################################
check_dependencies() {
    local deps=(awk sed grep date tar iconv column mktemp tr)
    local missing_deps=()
    local dep
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        printf "Error: The following required dependencies are missing: %s\n" "${missing_deps[*]}"
        exit 1
    fi
}

#######################################
# Detects if GNU date is installed and sets aliases if needed.
# Arguments:
#   None
#######################################
date_version_detect() {
    if ! date --version >/dev/null 2>&1; then
        if gdate --version >/dev/null 2>&1 ; then
            date() {
                gdate "$@"
            }
        else
            date() {
                if [[ "$1" == "-r" ]]; then
                    local format="${3//+/}"
                    stat -f "%Sm" -t "$format" "$2"
                elif [[ "${2:-}" == --date* ]]; then
                    command date -j -f "$date_format_full" "${2#--date=}" "$1"
                else
                    command date -j "$@"
                fi
            }
        fi
    fi
}

#######################################
# Main execution function.
# Arguments:
#   $@: Command line arguments.
#######################################
do_main() {
    check_dependencies
    date_version_detect
    global_variables
    if [[ -f "$GLOBAL_CONFIG" ]]; then
        # shellcheck disable=SC1090
        source "$GLOBAL_CONFIG" &> /dev/null
    fi
    global_variables_check

    if [[ -z "${EDITOR:-}" ]]; then
        printf "Please set your \$EDITOR environment variable. For example, to use nano, add the line 'export EDITOR=nano' to your \$HOME/.bashrc file\n"
        exit 1
    fi

    if [[ $# -lt 1 ]]; then
        usage
        exit 0
    fi

    case "$1" in
        reset|post|rebuild|list|edit|delete|tags) ;;
        *) usage; exit 0 ;;
    esac

    if [[ "$1" == "list" ]]; then
        list_posts
        exit 0
    fi

    if [[ "$1" == "tags" ]]; then
        list_tags "$@"
        exit 0
    fi

    if [[ "$1" == "edit" ]]; then
        if (($# < 2)) || [[ ! -f "${!#}" ]]; then
            printf "Please enter a valid .md or .html file to edit\n"
            exit 1
        fi
    fi

    if ls ./*.html &> /dev/null; then
        if tar -c -z -f ".backup.tar.gz" -- *.html; then
            chmod 600 ".backup.tar.gz"
        fi
    elif [[ "$1" == "rebuild" ]]; then
        printf "Can't find any html files, nothing to rebuild\n"
        exit 1
    fi

    if [[ -f ".backup.tar.gz" ]]; then
        if [[ ! -f .yesterday.tar.gz || $(date -r .yesterday.tar.gz +'%d') != "$(date +'%d')" ]]; then
            cp .backup.tar.gz .yesterday.tar.gz &> /dev/null || true
        fi
    fi

    if [[ "$1" == "reset" ]]; then
        reset
        exit 0
    fi

    create_css
    create_includes
    if [[ "$1" == "post" ]]; then
        write_entry "$@"
    elif [[ "$1" == "rebuild" ]]; then
        rebuild_all_entries
        rebuild_tags
    elif [[ "$1" == "delete" ]]; then
        rm -f "$2" &> /dev/null || true
        rebuild_tags
    elif [[ "$1" == "edit" ]]; then
        if [[ "${2:-}" == "-n" ]]; then
            edit "$3"
        elif [[ "${2:-}" == "-f" ]]; then
            edit "$3" full
        else
            edit "$2" keep
        fi
    fi
    rebuild_index
    all_posts
    all_tags
    make_rss
    delete_includes
}

# MAIN
do_main "$@"

# vim: set shiftwidth=4 tabstop=4 expandtab:
