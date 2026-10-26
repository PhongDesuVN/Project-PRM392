package com.prm.backend.dto.notebook;

import java.util.List;

public final class NotebookDtos {

        private NotebookDtos() {
        }

        public record NotebookProgressItem(
                        String word,
                        String reading,
                        String romaji,
                        String meaning,
                        String status // 'chua_thuoc', 'thuoc_lo_mo', 'thuoc_kha_kha', 'thuoc_lau_lau'
        ) {
        }

        public record NotebookSyncRequest(
                        List<NotebookProgressItem> words) {
        }

        public record NotebookStatsResponse(
                        int chuaThuoc,
                        int thuocLoMo,
                        int thuocKhaKha,
                        int thuocLauLau,
                        int total) {
        }

        public record NotebookWordItem(
                        Integer id,
                        String word,
                        String reading,
                        String romaji,
                        String meaning,
                        String status,
                        int reviewCount) {
        }

        public record NotebookWordsResponse(
                        List<NotebookWordItem> words) {
        }
}
