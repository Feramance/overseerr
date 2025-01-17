import type { QualityProfile, RootFolder, Tag } from '@server/api/servarr/base';
import type { LanguageProfile } from '@server/api/servarr/sonarr';

export interface ServiceCommonServer {
  id: number;
  name: string;
  is4k: boolean;
  isAnime: boolean;
  isDefault: boolean;
  activeProfileId: number;
  activeDirectory: string;
  activeLanguageProfileId?: number;
  activeTags: number[];
}

export interface ServiceCommonServerWithDetails {
  server: ServiceCommonServer;
  profiles: QualityProfile[];
  rootFolders: Partial<RootFolder>[];
  languageProfiles?: LanguageProfile[];
  tags: Tag[];
}
